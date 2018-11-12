extends "res://Scripts/Interactable.gd"

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

func action_performed():
	_begin_fishing(_actor)
	
func _get_fish_list():
	var file = File.new()
	file.open("Scripts/fishes.json", File.READ)
	var text = file.get_as_text()
	file.close()
	var fish_list = parse_json(text)
	return fish_list
	
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
		yield(timer, "timeout")
		
	timer.queue_free()
	
	if caught_fish == true:
		_print_message("%s caught %s!\n%s scored %d points.\n" % [fisher.name, fish.name, fisher.name, fish.score])
		level.add_score(fisher.player_id, fish.score)