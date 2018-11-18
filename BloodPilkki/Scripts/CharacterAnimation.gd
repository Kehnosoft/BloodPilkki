extends Spatial

var animation_player

func _ready():
	animation_player = find_node("AnimationPlayer")
	animation_player.play("Idle-loop")

func set_animation(animation):
	if animation == "walk":
		switch_animation("Walk-loop")
	if animation == "idle":
		switch_animation("Idle-loop")

func switch_animation(animation):
	if animation_player.current_animation != animation:
		animation_player.play(animation)