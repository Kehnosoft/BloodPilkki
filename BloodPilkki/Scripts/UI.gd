extends Control

var Types = load("res://Scripts/Types.gd")

var level = null
var ready = false

var action_timer = null
var action_timer_bar = null
var action_time_left = null

var score_bar = null
var fatigue_bar = null

func _ready():
	level = get_owner()
	action_timer = find_node("ActionTimerContainer")
	action_timer_bar = find_node("ActionTimerProgressBar")
	action_time_left = find_node("ActionTimeLeft")
	action_timer.hide()

	score_bar = find_node("ScoreBar")
	fatigue_bar = find_node("FatigueBar")

	ready = true
	
func _process(delta):
	if not ready:
		return
	
	_update_ui()
	
func _update_ui():
	score_bar.set_value(level.score)
	fatigue_bar.set_value(level.fatigue)

func reset_action_timer():
	action_timer_bar.set_value(0.0)
	action_time_left.set_text("0")

func show_action_timer():
	reset_action_timer()
	action_timer.show()

func hide_action_timer():
	action_timer.hide()
	reset_action_timer()

func update_action_timer(elapsed, action_time):
	var progress_percent = elapsed / action_time * 100.0
	var time_left = action_time - elapsed
	action_timer_bar.set_value(progress_percent)
	action_time_left.set_text("%.2fs" % time_left)