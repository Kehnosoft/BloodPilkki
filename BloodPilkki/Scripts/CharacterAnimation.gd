extends Spatial

var Types = load("res://Scripts/Types.gd")
var IDLE = "idle"
var RUN = "run"
var WALK = "walk"
var ATTACK = "attack"
var DAMAGE = "damage"

var animation_player
var _current_animation = null

var mapping = {
	Types.IDLE: IDLE,
	Types.RUN: RUN,
	Types.WALK: WALK,
	Types.ATTACK: ATTACK,
	Types.DAMAGE: DAMAGE
}
var animations = {
	IDLE: "idle-loop",
	RUN: "run-loop",
	WALK: "walk-loop",
	ATTACK: "punch_heavy",
	DAMAGE: "damage"
}

var blendable_animations = [ATTACK, DAMAGE]

func _ready():
	animation_player = find_node("AnimationPlayer")
	set_animation(Types.IDLE)

func set_animation(animation):
	animation = mapping[animation]
	if _current_animation == animation:
		return

	if animation in blendable_animations:
		animation_player.set_blend_time(_current_animation, animation, 0)
	
	animation_player.play(animations[animation])
	_current_animation = animation