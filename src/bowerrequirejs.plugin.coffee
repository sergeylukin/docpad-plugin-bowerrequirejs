# Export Plugin
module.exports = (BasePlugin) ->
	# Define Plugin
	class BowerRequirejsPlugin extends BasePlugin
		# Plugin name
		name: 'bowerrequirejs'

		writeAfter: (opts, next) ->
			# Prepare
			{collection} = opts

			console.log "Yo! Ready"
			console.log opts
			console.log "Yo.."

			# Done
			return
