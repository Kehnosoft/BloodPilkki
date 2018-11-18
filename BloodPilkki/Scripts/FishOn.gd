extends CanvasLayer

func _ready():
	randomize()

func strike():
	var fish_list = _get_fish_list()
	var roll = randi() % 101
	for fish in fish_list:
		if roll >= fish.DC:
			_reel_in(fish)
			break
	
func _get_fish_list():
	var file = File.new()
	file.open("Scripts/fishes.json", File.READ)
	var text = file.get_as_text()
	file.close()
	var fish_list = parse_json(text)
	return fish_list
			
func _print_message(msg):
	print(msg)
	
func _reel_in(fish):
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
		_print_message("Caught %s and scored %d points.\n" % [fish.name, fish.score])
