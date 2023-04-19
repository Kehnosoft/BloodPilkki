extends CharacterBody3D

var Types = load("res://Scripts/Types.gd")

var player_id = 0
var player_id_string = ""
var level = null
var center = null
var ui = null
var character = null

const FAST_ATTACK_SPEED = 20
const SLOW_ATTACK_SPEED = 40
var hitpoints = 0.0
var fast_attack = [10.0, 15.0, FAST_ATTACK_SPEED]
var heavy_attack = [15.0, 25.0, SLOW_ATTACK_SPEED]
var damage_mod = 1.0

var player_velocity = Vector3()

var _dead = false
var _actioning = false
var _attacking = false
var _action_debounce = false
var _returning_to_idle = false
var _action_timer = 0.0
var _attack_timer = 0.0
var _current_attack_speed = 0.0
var _available_action_targets = []
var _available_attack_targets = []
var _action_target = null
var _attack_target = null
var _weapon = null

const GRAVITY = 9.8
const SPEED = 18.5
const ACCEL = 3.5
const DEACCEL = 8

const DEAD_ZONE = 0.2
const ROTATION_SPEED = 0.15

const HITPOINTS = 100.0

const ANIMATION_IDLE_LIMIT = 0.5

func _ready():
	level = get_owner()
	center = level.get_global_transform()
	ui = level.find_child("UI")
	character = find_child("Character")
	character.set_animation(Types.Animations.IDLE)
	hitpoints = 100.0
	
func set_player_color(col):
	#var mat = find_child("character").get_surface_override_material(0).duplicate()
	#mat.set_shader_parameter("albedo", col)
	#find_child("character").set_surface_override_material(0, mat)
	pass
	
func set_player_id(id):
	player_id = id
	player_id_string = "player_%d" % player_id
	
func respawn():
	_dead = false
	hitpoints = HITPOINTS
	
func give_weapon(weapon):
	_weapon = weapon
	
func is_dead():
	return self._dead
	
func _physics_process(delta):
	if player_id == 0 or _dead:
		return

	_handle_movement(delta)
	_handle_actions(delta)
	_handle_attacks()

############
# Movement #
############
func _handle_movement(delta):
	var dir = Vector3()
	dir.y = 0
	if Input.get_connected_joypads().size() > 0:
		# Gamepad controls.
		dir.x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
		if abs(dir.x) < DEAD_ZONE:
			dir.x = 0.0
			
		dir.z = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
		if abs(dir.z) < DEAD_ZONE:
			dir.z = 0.0
			
	# Keyboard controls
	if Input.is_action_pressed('%s_move_up' % player_id_string):
		dir += -center.basis[2]
	if Input.is_action_pressed('%s_move_down' % player_id_string):
		dir += center.basis[2]
	if Input.is_action_pressed('%s_move_left' % player_id_string):
		dir += -center.basis[0]
	if Input.is_action_pressed('%s_move_right' % player_id_string):
		dir += center.basis[0]
	
	dir = dir.normalized()
	velocity.y += delta * -GRAVITY
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
	
	hv = hv.lerp(new_pos, accel * delta)
	velocity.x = hv.x
	velocity.z = hv.z
	set_velocity(velocity)
	set_up_direction(Vector3(0, 1, 0))
	move_and_slide()
	velocity = velocity
	
	# Player animation
	var moving = Vector2(velocity.x, velocity.z).length() > ANIMATION_IDLE_LIMIT
	if moving:
		character.set_animation(Types.Animations.RUN)
	
	if not moving and not _attacking:
		_returning_to_idle = true

	if _returning_to_idle:
		character.set_animation(Types.Animations.IDLE)
		_returning_to_idle = false

############
# Fighting #
############
func _handle_attacks():
	# Attacks	
	var key_fast_attack = Input.is_action_pressed('%s_fast_attack' % player_id_string) 
	var pad_fast_attack = Input.is_joy_button_pressed(0, JOY_BUTTON_X)
	if (key_fast_attack or pad_fast_attack):
		_try_start_attack(fast_attack)
		
	var key_heavy_attack = Input.is_action_pressed('%s_heavy_attack' % player_id_string) 
	var pad_heavy_attack = Input.is_joy_button_pressed(0, JOY_BUTTON_Y)
	if (key_heavy_attack or pad_heavy_attack):
		_try_start_attack(heavy_attack)
		
	if _attacking:
		if _attack_timer >= _current_attack_speed:
			_stop_the_attack()
		else:
			_attack_timer += 1

func _try_start_attack(attack):
	if not _attacking:
		_attacking = true
		_attack_timer = 0.0
		_current_attack_speed = attack[2]
		for target in _available_attack_targets:
			_attack(target, attack)
		character.set_animation(Types.Animations.ATTACK)

func _stop_the_attack():
	_attacking = false
	_attack_timer = 0.0
	_returning_to_idle = true

func _die():
	print("%s dies" % self.name)
	_dead = true
	level.player_killed(self)
			
func take_damage(damage):
	if not _dead:
		character.set_animation(Types.Animations.DAMAGE)
		hitpoints -= damage
		if hitpoints <= 0:
			_die()

func _attack(target, attack):
	if target.is_dead():
		return
	
	var weapon_damage = [1, 1]
	if _weapon:
		weapon_damage = [_weapon.min_damage, _weapon.max_damage]
		
	var min_dmg = attack[0] * weapon_damage[0]
	var max_dmg = attack[1] * weapon_damage[1]
	var damage = randf_range(min_dmg, max_dmg)
	target.take_damage(damage)
	
	var weapon_str = ""
	if _weapon:
		weapon_str = " with %s" % _weapon.name
		
	print("%s attacks %s%s for %.2f damage" % [self.name, target.name, weapon_str, damage])

###########
# Actions #
###########
func _handle_actions(delta):
	# Actions
	var key_action = Input.is_action_pressed('%s_action' % player_id_string) 
	var pad_action = Input.is_joy_button_pressed(0, JOY_BUTTON_A)
	if key_action or pad_action:
		if _actioning and not _action_debounce:
			_perform_timed_action(delta)
		else:
			_try_start_action()
	elif _actioning:
		_stop_action()

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
	if len(_available_action_targets) > 0:
		return
	target.show_action_indicator()
	_available_action_targets.append(target)

func remove_available_action(target):
	for i in range(0, len(_available_action_targets)):
		if _available_action_targets[i] == target:
			_available_action_targets.remove(i)
			target.hide_action_indicator()
