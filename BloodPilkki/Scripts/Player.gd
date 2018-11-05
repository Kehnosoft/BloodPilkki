extends KinematicBody

var player_id = 0
var level = null
var center = null
var ui = null

var hitpoints = 0.0
var fast_damage = [10.0, 15.0]
var heavy_damage = [15.0, 25.0]
var damage_mod = 1.0

var gravity = -9.8
var velocity = Vector3()

var _dead = false
var _actioning = false
var _attacking = false
var _action_debounce = false
var _action_timer = 0.0
var _attack_timer = 0.0
var _available_action_targets = []
var _available_attack_targets = []
var _action_target = null
var _attack_target = null

const SPEED = 10
const ACCEL = 3.5
const DEACCEL = 8

const DEAD_ZONE = 0.2
const ROTATION_SPEED = 0.15

const ATTACK_SPEED = 20

func _ready():
	level = get_owner()
	center = level.get_global_transform()
	ui = level.find_node("UI")
	
	hitpoints = 100.0

func _physics_process(delta):
	var dir = Vector3()
	dir.y = 0
	
	if Input.get_connected_joypads().size() > 0:
		# Gamepad controls.
		dir.x = Input.get_joy_axis(0, JOY_AXIS_0)
		if abs(dir.x) < DEAD_ZONE:
			dir.x = 0.0
			
		dir.z = Input.get_joy_axis(0, JOY_AXIS_1)
		if abs(dir.z) < DEAD_ZONE:
			dir.z = 0.0
			
	# Keyboard controls
	var player = "player_%d" % player_id
	if Input.is_action_pressed('%s_move_up' % player):
		dir += -center.basis[2]
	if Input.is_action_pressed('%s_move_down' % player):
		dir += center.basis[2]
	if Input.is_action_pressed('%s_move_left' % player):
		dir += -center.basis[0]
	if Input.is_action_pressed('%s_move_right' % player):
		dir += center.basis[0]
	
	var key_action = Input.is_action_pressed('%s_action' % player) 
	var pad_action = Input.is_joy_button_pressed(0, JOY_XBOX_A)
	if key_action or pad_action:
		if _actioning and not _action_debounce:
			_perform_timed_action(delta)
		else:
			_try_start_action()
	elif _actioning:
		_stop_action()
		
	var key_fast_attack = Input.is_action_pressed('%s_fast_attack' % player) 
	var pad_fast_attack = Input.is_joy_button_pressed(0, JOY_XBOX_X)
	if (key_fast_attack or pad_fast_attack):
		_try_start_attack()
		
	if _attacking:
		if _attack_timer >= ATTACK_SPEED:
			_stop_the_attack()
		else:
			_attack_timer += 1

	dir = dir.normalized()
	velocity.y += delta * gravity
	var hv = velocity
	hv.y = 0
	
	var new_pos = dir * SPEED
	var accel = DEACCEL
	if dir.dot(hv) > 0:
		accel = ACCEL
		

	# Rotate the character based on movement direction
	if Vector2(velocity.x, velocity.z).length() > 0.1:
		var angle = atan2(velocity.x, velocity.z)
		var current_rotation = get_rotation()
		var difference = max(angle, current_rotation.y) - min(angle, current_rotation.y)

		var rotation_direction_multiplier = 1.0
		if current_rotation.y < angle:
			if angle - current_rotation.y > PI:
				rotation_direction_multiplier = -1.0
		else:
			if current_rotation.y - angle <= PI:
				rotation_direction_multiplier = -1.0
		
		if difference < ROTATION_SPEED:
			rotate_y(difference * rotation_direction_multiplier)
		else:
			rotate_y(ROTATION_SPEED * rotation_direction_multiplier)

	hv = hv.linear_interpolate(new_pos, accel * delta)
	velocity.x = hv.x
	velocity.z = hv.z
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))

func _try_start_attack():
	if not _attacking:
		_attacking = true
		_attack_timer = 0.0
		for target in _available_attack_targets:
			_attack(target)
		
func _stop_the_attack():
	_attacking = false
	_attack_timer = 0.0

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
			
func _die():
	print("%s dies" % self.name)
	_dead = true
	self.rotate(Vector3(1, 0, 0), 90)
			
func take_damage(damage):
	if not _dead:
		hitpoints -= damage
		if hitpoints <= 0:
			_die()
			
func _attack(target):
	var damage = rand_range(fast_damage[0], fast_damage[1])
	target.take_damage(damage)
	print("%s attacks %s for %.2f damage" % [self.name, target.name, damage])