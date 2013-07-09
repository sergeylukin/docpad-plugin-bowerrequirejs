# Export Plugin
module.exports = (BasePlugin) ->

	requirejs = require('requirejs/bin/r.js')
	path = require('path')
	fs = require('fs')
	bower = require('bower')
	_ = require('underscore')
	levenshtein = require('levenshtein-distance')

	# Define Plugin
	class BowerRequirejsPlugin extends BasePlugin
		# Plugin name
		name: 'bowerrequirejs'

		# Plugin configuration
		config:
			# By default only enalbed in static environment
			enabled: false
			environments:
				static:
					enabled: true
			# Specify bower component names (like `jquery`, `almond`, etc.)
			# you don't want to be linked
			excludes: []
			rjsConfig: 'scripts/main.js'

		writeAfter: (opts, next) ->

			# Prepare
			{collection} = opts
			docpad = @docpad
			config = @config

			# TODO: move this out to configuration
			configFilePath = path.join docpad.config.outPath, config.rjsConfig
			configFile = String( fs.readFileSync String(configFilePath) )
			baseUrl = path.dirname configFilePath

			require('bower').commands.list({paths: true})
				.on 'data', (components) ->

					if components

						# remove excludes and clean up key names
						_.each components, (val, key, obj) ->
							if config.excludes.indexOf(key) isnt -1
								delete obj[key]
								return

							# clean up path names like 'typeahead.js'
							# when requirejs sees the .js extension it will assume
							# an absolute path, which we don't want.
							if path.extname(key) is ".js"
								newKey = key.replace(/\.js$/, "")
								obj[newKey] = obj[key]
								delete obj[key]

								console.log "Warning: Renaming " + key + " to " + newKey

							if not _.isArray(val)
								# If path set in bower leads to a directory
								# try to find file in it by ourselves..
								if fs.statSync(val).isDirectory()
									jsfiles = _.filter fs.readdirSync(val), (fileName) ->
										return path.extname(fileName) is ".js" && fileName != 'Gruntfile.js'

									# Find best match using levenshtein distance
									# algorithm if there are many .js files
									if jsfiles.length > 1
										new levenshtein(jsfiles).find key, (res) ->
											obj[key] = path.join(val, res)
									# Assign the only one that was found
									else if jsfiles.length == 1
										obj[key] = path.join(val, jsfiles[0])

									# Ignore component if no .js file found
									else
										delete obj[key]

						console.log components

						requirejs.tools.useLib (require) ->
							rjsConfig = require("transform").modifyConfig configFile, (config) ->
								_.each components, (val, key, obj) ->
									
									# if main is not an array convert it to one so we can
									# use the same process throughout
									val = [val]  unless _.isArray(val)
									
									# iterate through the main array and filter it down
									# to only .js files
									jsfiles = _.filter val, (inval) ->
										path.extname(inval) is ".js"
									
									# if there are no js files in main, delete
									# the path and return
									unless jsfiles.length
										delete obj[key]

										return
									
									# strip out any .js file extensions to make
									# requirejs happy
									jsfiles = _.map jsfiles, (file) ->
										path.join(path.dirname(file), path.basename(file, ".js"))

									
									# if there were multiple js files create a path
									# for each using its filename.
									if jsfiles.length > 1
										
										# remove the original key to array relationship since we're
										# splitting the component into multiple paths
										delete obj[key]

										_.forEach jsfiles, (jsfile) ->
											jspath = path.relative(baseUrl, jsfile)
											obj[path.basename(jspath).split(".")[0]] = jspath

									
									# if there was only one js file create a path
									# using the key
									else
										obj[key] = path.relative(baseUrl, jsfiles[0])

								_.extend config.paths, components
								config

							fs.writeFile configFilePath, rjsConfig, (err) ->
								console.log "Updated RequireJS config with installed Bower components"

					# Done
					next?()

				.on 'error', (err) ->
					next?(err)

