extends Control

var Types = load("res://Scripts/Types.gd")
var Strings = load("res://Scripts/Strings.gd")

var level = null
var ready = false
var messages = []

func _ready():
	level = get_owner()
	ready = true
	
func _process(delta):
	if not ready:
		return
	_update_ui()
	
func _update_ui():
	var game_state = level.get_game_state()
	var players = level.get_players()
	var scores = level.get_scores()
	var available_tasks = level.get_holes()
	
	# Show gamestate
	var debug_game_state = find_node("DebugGameStateValue")
	debug_game_state.set_text(Strings.game_state(game_state))
	
	# Update the hole list
	# Clear the current list
	var debug_hole_list = find_node("DebugHoleList")
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