class Printer:
	var _debugging = null
	var _debug_ui = null
	var _ui = null

	func _init(ui=null, debugging=null, debug_ui=null):
		self._debugging = null
		self._debug_ui = null
		self._ui = null
	 
	func print_message(message, debug_only=false):
		if self._debugging:
			print(message)
			if self._debug_ui:
				self._debug_ui.print_message(message)
				
		if not debug_only and self._ui:
			self._ui.print_message(message)