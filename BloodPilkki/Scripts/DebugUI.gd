extends Control

var Types = load("res://Scripts/Types.gd")
var Strings = load("res://Scripts/Strings.gd")

var level = null

var messages = []

var ui_ready = false

func _ready():
	level = get_owner()
	ui_ready = true
	
func _process(delta):
	if not ui_ready:
		return
	_update_ui()
	
func _update_ui():
	var game_state = level.get_game_state()
	
	# Show gamestate
	var debug_game_state = find_child("DebugGameStateValue")
	debug_game_state.set_text(Strings.game_state(game_state))
	
	# Update the hole list
	# Clear the current list
	var debug_hole_list = find_child("DebugHoleList")
	for hole in debug_hole_list.get_children():
		debug_hole_list.remove_child(hole)
	
	# Refresh the list with new holes
	for hole in level.get_holes():
		var taskLabel = Label.new()
		taskLabel.set_text(Strings.hole_status(hole))
		debug_hole_list.add_child(taskLabel)
	
func refresh_messages():
	pass
	
func print_message(message):
	messages += message
	refresh_messages()
