# Export Plugin
module.exports = (BasePlugin) ->

	requirejs = require('requirejs/bin/r.js')
	path = require('path')
	fs = require('fs')
	_ = require('underscore')

	# Define Plugin
	class BowerRequirejsPlugin extends BasePlugin
		# Plugin name
		name: 'bowerrequirejs'

		writeAfter: (opts, next) ->

			# Prepare
			{collection} = opts
			docpad = @docpad
			configFilePath = path.normalize "#{docpad.config.rootPath}/.tmp/scripts/main.js"
			configFile = String( fs.readFileSync String(configFilePath) )
			baseUrl = path.dirname configFilePath

			require('bower').commands.list({paths: true})
				.on 'data', (data) ->
					excludes = []

					if data

						# remove excludes and clean up key names
						_.each data, (val, key, obj) ->
							if excludes.indexOf(key) isnt -1
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
							
							# if there's no main attribute in the bower.json file, for example:
							# "almond": "bower_components/almond/"
							# ..then look for a top level .js file, so we want this:
							# "almond": "bower_components/almond/almond.js"
							# assuming almond.js exists
							# if we don't find one continue to use the original value.
							# if we find any Gruntfiles, remove them
							if not _.isArray(val)
								if fs.statSync(val).isDirectory()
									files = fs.readdirSync val
									main = _.filter files, (fileName) ->
										return path.extname(fileName) is ".js" && fileName != 'Gruntfile.js'
									obj[key] = (if main.length is 1 then path.join(val, main[0]) else val)

						requirejs.tools.useLib (require) ->
							rjsConfig = require("transform").modifyConfig configFile, (config) ->
								_.each data, (val, key, obj) ->
									
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

								_.extend config.paths, data
								config

							fs.writeFile configFilePath, rjsConfig, (err) ->
								console.log "Updated RequireJS config with installed Bower components"

					# Done
					next?()

				.on 'error', (err) ->
					next?(err)

