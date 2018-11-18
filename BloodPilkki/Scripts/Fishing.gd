extends Control

signal fishing_complete(outcome)

var indicator
var state = "idle"
var strike_bar = null
var strike_value
var reaction_timer

func _ready():
	indicator = find_node("Indicator")
	strike_bar = find_node("StrikeProgress")
	reaction_timer = find_node("ReactionTimer")
	randomize()
	
func _process(delta):
	if state == "fishing":
		if _is_action_button_pressed():
			print ("Too early!")
			fishing_complete(false)
			
		strike_value += 1
		strike_bar.set_value(strike_value)
		if strike_value >= 100:
			print ("Set the hook!")
			reaction_timer.start()
			state = "fish on"
	
	if state == "fish on":
		if reaction_timer.is_stopped():
			print ("Too slow!")
			fishing_complete(false)
		else:
			if _is_action_button_pressed():
				print ("Fish on!")
				fishing_complete(true)
	
func begin_fishing():
	strike_value = 0
	state = "fishing"
	
func fishing_complete(outcome):
	state = "idle"
	emit_signal("fishing_complete", outcome)
	
#################
# Button filter #
#################
func _is_action_button_pressed():
	var is_action_button
	if (Input.is_action_just_pressed("player_1_action") or Input.is_joy_button_pressed(0, JOY_XBOX_A)) and strike_value > 0:
		is_action_button = true
	else:
		is_action_button = false
	return is_action_button
