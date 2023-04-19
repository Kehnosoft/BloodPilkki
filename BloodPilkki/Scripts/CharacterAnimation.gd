extends Node3D

var Types = load("res://Scripts/Types.gd")
var IDLE = "idle"
var RUN = "run"
var WALK = "walk"
var ATTACK = "attack"
var RUN_PUNCH = "run_punch"
var DAMAGE = "damage"

var animation_player
var _current_animation = null

var mapping = {
	Types.Animations.IDLE: IDLE,
	Types.Animations.RUN: RUN,
	Types.Animations.WALK: WALK,
	Types.Animations.ATTACK: ATTACK,
	Types.Animations.RUN_PUNCH: RUN_PUNCH,
	Types.Animations.DAMAGE: DAMAGE
}
var animations = {
	IDLE: "idle-loop",
	RUN: "run-loop",
	WALK: "walk-loop",
	ATTACK: "punch_heavy",
	RUN_PUNCH: "run_punch-loop",
	DAMAGE: "damage"
}

var blendable_animations = [ATTACK, DAMAGE]

func _ready():
	animation_player = find_child("AnimationPlayer")
	set_animation(Types.Animations.IDLE)

func set_animation(animation):
	animation = mapping[animation]
	if _current_animation == animation:
		return

	if animation in blendable_animations:
		animation_player.set_blend_time(_current_animation, animation, 0)
	
	animation_player.play(animations[animation])
	_current_animation = animation
