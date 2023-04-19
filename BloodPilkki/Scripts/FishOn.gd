extends CanvasLayer

signal fish_on_complete(catch, points)

var reel_in_bar = null
var progress_percent = 50
var _fish = null
var player_strength = 3.5

func _ready():
	randomize()
	reel_in_bar = find_child("ReelInProgress")
	
func strike():
	var fish_list = _get_fish_list()
	var roll = randi() % 101
	for fish in fish_list:
		if roll >= fish.DC:
			_reel_in(fish)
			break
			
func hide():
	reel_in_bar.hide()
	
func show():
	reel_in_bar.show()
	
func _get_fish_list():
	var file = File.new()
	file.open("Scripts/fishes.json", File.READ)
	var text = file.get_as_text()
	file.close()
	var test_json_conv = JSON.new()
	test_json_conv.parse(text)
	var fish_list = test_json_conv.get_data()
	return fish_list
			
func _print_message(msg):
	print(msg)
	
func _reel_in(fish):
	_print_message("\nStrike! %s" % [fish.message])
	progress_percent = 50
	_fish = fish
	
func _process(delta):
	if _fish != null:
		if _action_button_pressed():
			progress_percent += player_strength
		progress_percent -= _fish.strength * delta
		reel_in_bar.set_value(progress_percent)
		if progress_percent <= 0:
			emit_signal("fish_on_complete", null, 0)
			_fish = null
		if progress_percent >= 100:
			emit_signal("fish_on_complete", _fish.name, _fish.score)
			_fish = null

#################
# Button filter #
#################
var action_button_filter = 0
var action_button_filter_limit = 1
var previous_action_button_state = false

func _action_button_pressed():
	var is_action_button_pressed = Input.is_action_just_pressed("player_1_action")
	
	# Filter gamepad button
	if action_button_filter == 0:
		if previous_action_button_state == false:
			previous_action_button_state = Input.is_joy_button_pressed(0, JOY_XBOX_A)
			is_action_button_pressed = is_action_button_pressed or previous_action_button_state
			if previous_action_button_state == true:
				action_button_filter = action_button_filter_limit
		else:
			previous_action_button_state = Input.is_joy_button_pressed(0, JOY_XBOX_A)
			action_button_filter = action_button_filter_limit
	else:
		action_button_filter -= 1
		
	return is_action_button_pressed
