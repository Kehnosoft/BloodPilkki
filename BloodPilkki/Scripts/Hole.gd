extends "res://Scripts/Interactable.gd"

signal fishing_complete

var Types = load("res://Scripts/Types.gd")
var Strings = load("res://Scripts/Strings.gd")

var level = null
var id = null
var lifetime = 0

func _ready():
	level = get_owner()
	lifetime = 0
	name = get_name()
	randomize()
	self.connect("fishing_complete", Callable(level, "_on_fishing_complete"))

func action_performed():
	_begin_fishing(_actor)
	
func _get_fish_list():
	#var file = File.new()
	#file.open("Scripts/fishes.json", File.READ)
	#var text = file.get_as_text()
	#file.close()
	#var test_json_conv = JSON.new()
	#test_json_conv.parse(text)
	#var fish_list = test_json_conv.get_data()
	#return fish_list
	
	return [
		{"name" : "Ancient Pike", "DC" : 100, "score" : 20, "strength" : 20, "message" : "The skies darken as the COLOSSAL catch begins its struggle!"},
		{"name" : "Salmon King", "DC" : 95, "score" : 16, "strength" : 19, "message" : "It's MASSIVE!"},
		{"name" : "Pike Emperor", "DC" : 90, "score" : 14, "strength" : 18, "message" : "It's MASSIVE!"},
		{"name" : "Pike Lord", "DC" : 85, "score" : 12, "strength" : 16, "message" : "It's HUGE!"},
		{"name" : "Perch President", "DC" : 80, "score" : 10, "strength" : 14, "message" : "It's HUGE!"},
		{"name" : "Salmon", "DC" : 65, "score" : 7, "strength" : 13, "message" : "It's a BIG one!"},
		{"name" : "Pike", "DC" : 55, "score" : 5, "strength" : 12, "message" : "It's a BIG one!"},
		{"name" : "Perch", "DC" : 40, "score" : 3, "strength" : 3, "message" : "Reeling in easy."},
		{"name" : "Roach", "DC" : 20, "score" : 2, "strength" : 2, "message" : "Reeling in easy."},
		{"name" : "Ruffe", "DC" : 0, "score" : 1, "strength" : 1, "message" : "Reeling in easy."},
	]
	
func _begin_fishing(fisher):
	var fish_list = _get_fish_list()
	var roll = randi() % 101
	for fish in fish_list:
		if roll >= fish.DC:
			_fish(fisher, fish)
			break
			
func _print_message(msg):
	print(msg)
	level.Printer.print_message(msg)
	
func _fish(fisher, fish):
	_print_message("\nStrike! %s" % [fish.message])
	
	var trying_to_escape = false
	var caught_fish = false
	
	var timer = Timer.new()
	timer.set_wait_time(1)
	timer.set_one_shot(true)
	self.add_child(timer)
	
	while true:
		var roll = randi() % 20
		if trying_to_escape == false:
			if roll <= fish.strength:
				_print_message("The fish tries to escape!")
				trying_to_escape = true
			else:
				_print_message("You reel the catch in!")
				caught_fish = true
				break
		else:
			if roll + 10 < fish.strength:
				_print_message("The fish broke the line!")
				break
			else:
				_print_message("You manage to take over control...")
				trying_to_escape = false
		
		timer.start()
		await timer.timeout
		
	timer.queue_free()
	
	if caught_fish == true:
		emit_signal("fishing_complete", fisher, fish.score)
