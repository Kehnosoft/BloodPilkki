extends Control

var Types = load("res://Scripts/Types.gd")

var level = null
var ui_ready = false

var respawn_timer = null
var respawn_timer_bar = null
var respawn_time_left = null

func _ready():
	level = get_owner()
	
	respawn_timer = find_child("RespawnTimerContainer")
	respawn_timer_bar = find_child("RespawnTimerProgressBar")
	#respawn_time_left = find_node("RespawnTimeLeft")

	ui_ready = true
	
func _process(delta):
	if not ui_ready:
		return
	_update_ui()
	
func _update_ui():
	update_respawn_timer()

func update_respawn_timer():
	var respawn_time = level.RESPAWN_TIMER
	var elapsed = level.get_respawn_time()
	var progress_percent = 100 - (elapsed / respawn_time * 100.0)
	var time_left = respawn_time - elapsed
	respawn_timer_bar.set_value(progress_percent)
	#respawn_time_left.set_text("%.2fs" % time_left)
