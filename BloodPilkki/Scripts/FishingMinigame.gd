extends Spatial

var fishing
var fish_on
var fishing_ongoing
var timer

func _ready():
	fishing = find_node("Fishing")
	fish_on = find_node("FishOn")
	
	fishing.connect("fishing_complete", self, "handle_fishing_complete")
	fish_on.connect("fish_on_complete", self, "handle_fish_on_complete")
	
	fishing.hide()
	fish_on.hide()
	
	timer = find_node("FishingTimer")
	
	fishing_ongoing = false

func _process(delta):
	if fishing_ongoing == false and _is_action_button_pressed():
		fishing_ongoing = true
		start_fishing()

#################
# Button filter #
#################
func start_fishing():
	fishing.show()
	fishing.begin_fishing()
	
func start_fish_on():
	fish_on.show()
	fish_on.strike()

#################
# Button filter #
#################
func _is_action_button_pressed():
	var is_action_button
	if Input.is_action_just_pressed("player_1_action") or Input.is_joy_button_pressed(0, JOY_XBOX_A):
		is_action_button = true
	else:
		is_action_button = false
	return is_action_button

###################
# Signal handlers #
###################
func handle_fishing_complete(outcome):
	fishing.hide()
	if outcome == true:
		print ("Strike...")
		start_fish_on()
	else:
		print ("The fish got away...")
		fishing_ongoing = false

func handle_fish_on_complete(name, score):
	if name == null:
		print ("It got away...")
	else:
		print ("You caught %s and got %s points!" % [name, score])
	fish_on.hide()
	timer.start()
	yield(timer, "timeout")
	fishing_ongoing = false