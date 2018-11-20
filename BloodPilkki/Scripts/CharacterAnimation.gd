extends Spatial

var animation_player

func _ready():
	animation_player = find_node("AnimationPlayer")
	animation_player.play("idle-loop")

func set_animation(animation):
	if animation == "run":
		switch_animation("run-loop")
	if animation == "walk":
		switch_animation("walk-loop")
	if animation == "idle":
		switch_animation("idle-loop")

func switch_animation(animation):
	if animation_player.current_animation != animation:
		animation_player.play(animation)