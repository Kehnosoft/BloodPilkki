extends KinematicBody

var player_id = 1
var level = null
var center = null
var ui = null

var gravity = -9.8
var velocity = Vector3()
var fatigue_mod = 1

var _actioning = false
var _action_debounce = false
var _action_timer = 0.0
var _available_action_targets = []
var _action_target = null

const SPEED = 10
const ACCEL = 3.5
const DEACCEL = 8

const DEAD_ZONE = 0.2
const ROTATION_SPEED = 0.1

func _ready():
	level = get_owner()
	center = level.get_global_transform()
	ui = level.find_node("UI")
	#level.printer.print_message("player %d ready" % player_id)

func _physics_process(delta):
	var dir = Vector3()
	dir.y = 0
	
	var player = "player_%d" % player_id
	if Input.get_connected_joypads().size() > 0:
		# Gamepad controls.
		dir.x = Input.get_joy_axis(0, JOY_AXIS_0)
		if abs(dir.x) < DEAD_ZONE:
			dir.x = 0.0
			
		dir.z = Input.get_joy_axis(0, JOY_AXIS_1)
		if abs(dir.z) < DEAD_ZONE:
			dir.z = 0.0
			
		if Input.is_joy_button_pressed(0, JOY_XBOX_A):
			if _actioning and not _action_debounce:
				_perform_timed_action(delta)
			else:
				_try_start_action()
		elif _actioning:
			_stop_action()
	else:
		# Keyboard controls
		if Input.is_action_pressed('%s_move_up' % player):
			dir += -center.basis[2]
		if Input.is_action_pressed('%s_move_down' % player):
			dir += center.basis[2]
		if Input.is_action_pressed('%s_move_left' % player):
			dir += -center.basis[0]
		if Input.is_action_pressed('%s_move_right' % player):
			dir += center.basis[0]
		if Input.is_action_pressed('%s_action' % player):
			if _actioning and not _action_debounce:
				_perform_timed_action(delta)
			else:
				_try_start_action()
		elif _actioning:
			_stop_action()
		
		dir = dir.normalized()
	
	velocity.y += delta * gravity
	var hv = velocity
	hv.y = 0
	
	var new_pos = dir * SPEED
	var accel = DEACCEL
	if dir.dot(hv) > 0:
		accel = ACCEL

	# Rotate the character based on movement direction
	if dir.length() > 0.0:
		var angle = atan2(velocity.x, velocity.z)
		var current_rotation = get_rotation()
		var turnCounterClocwise = false
		if current_rotation.y < angle:
			if angle - current_rotation.y <= PI:
				turnCounterClocwise = true
		else:
			if current_rotation.y - angle > PI:
				turnCounterClocwise = true
		if turnCounterClocwise == false:
			current_rotation.y += ROTATION_SPEED
			if current_rotation.y > PI:
				current_rotation.y -= 2*PI
		else:
			current_rotation.y -= ROTATION_SPEED
			if current_rotation.y < -PI:
				current_rotation.y += 2*PI
		set_rotation(current_rotation)

	hv = hv.linear_interpolate(new_pos, accel * delta)
	velocity.x = hv.x
	velocity.z = hv.z
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))

func _try_start_action():
	if not _actioning and _available_action_targets:
		_action_target = _available_action_targets[0]
		_actioning = true
		_action_timer = 0.0
		if _action_target.ACTION_TIME > 0:
			ui.show_action_timer()
		else:
			_action_debounce = true
			_action_target.action_performed()

func _perform_timed_action(delta):
	if not _action_target:
		_stop_action()
		return

	if _action_timer >= _action_target.ACTION_TIME:
		_action_target.action_performed()
		_stop_action()
		return
		
	_action_timer += delta
	ui.update_action_timer(_action_timer, _action_target.ACTION_TIME)

func _stop_action():
	_action_target = null
	_actioning = false
	_action_timer = 0.0
	_action_debounce = false
	#ui.hide_action_timer()
	
func add_available_action(target):
	# Waiting for a proper implementation
#	for t in _available_action_targets:
#		if t == target:
#			return

	if len(_available_action_targets) > 0:
		return
	target.show_action_indicator()
	_available_action_targets.append(target)

func remove_available_action(target):
	for i in range(0, len(_available_action_targets)):
		if _available_action_targets[i] == target:
			_available_action_targets.remove(i)
			target.hide_action_indicator()