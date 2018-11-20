extends Control

signal fishing_complete(outcome)

var indicator
var state = "idle"
var strike_bar = null
var strike_value
var reaction_timer
var pow_sprite
var pow_sfx

var transition_ongoing

var current_direction
var current_speed
var current_target_position

const FISH_STRIKE_PROBABILITY = 5
const STRIKE_COUNTER_MAX = 100
const STRIKE_TARGET_MAX = 90
const SPEED_MAX = 6
const SPEED_MULTIPLIER = 20
const STRIKE_SPEED = (SPEED_MAX + 3) * SPEED_MULTIPLIER

func _ready():
	indicator = find_node("Indicator")
	strike_bar = find_node("StrikeProgress")
	reaction_timer = find_node("ReactionTimer")
	pow_sprite = find_node("Pow")
	pow_sfx = find_node("PowSfx")
	pow_sprite.hide()
	randomize()
	
func _process(delta):
	if state == "fishing":
		if _is_action_button_pressed():
			print ("Too early!")
			fishing_complete(false)
		
		if transition_ongoing == false:
			if current_direction == "left" and fish_strikes():
				current_direction = "right"
				current_speed = STRIKE_SPEED
				current_target_position = STRIKE_COUNTER_MAX
			else:
				get_new_direction()
				get_speed()
				get_new_position()
			print ("Direction: ", current_direction)
			print ("Speed: ", current_speed)
			print ("Target: ", current_target_position)
			transition_ongoing = true
				
		if current_direction == "left":
			strike_value -= current_speed * delta
		else:
			strike_value += current_speed * delta
			
		strike_bar.set_value(strike_value)
		if strike_value >= STRIKE_COUNTER_MAX:
			handle_strike()
		else:
			if current_direction == "left" and strike_value <= current_target_position\
			or current_direction == "right" and strike_value >= current_target_position:
				transition_ongoing = false
				
	if state == "fish on":
		if reaction_timer.is_stopped():
			print ("Too slow!")
			fishing_complete(false)
		else:
			if _is_action_button_pressed():
				print ("Fish on!")
				fishing_complete(true)

func handle_strike():
	print ("Set the hook!")
	reaction_timer.start()
	state = "fish on"
	pow_sprite.show()
	pow_sfx.play()

func fish_strikes():
	var roll = randi() % 6
	var strikes
	if roll == FISH_STRIKE_PROBABILITY:
		strikes = true
	else:
		strikes = false
	return strikes
	
func get_new_direction():
	if strike_value == 0 or current_direction == "left":
		current_direction = "right"
	else:
		current_direction = "left"
	
func get_speed():
	current_speed = ((randi() % SPEED_MAX) + 1) * SPEED_MULTIPLIER
	
func get_new_position():
	if current_direction == "left":
		current_target_position = randi() % int(round(strike_value))
	else:
		current_target_position = randi() % (STRIKE_TARGET_MAX - int(round(strike_value))) + round(strike_value)
	
func begin_fishing():
	strike_value = 0
	transition_ongoing = false
	state = "fishing"
	
func fishing_complete(outcome):
	state = "idle"
	pow_sprite.hide()
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
