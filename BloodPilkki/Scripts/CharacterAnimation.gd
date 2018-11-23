extends Spatial

var animation_player

func _ready():
	animation_player = find_node("AnimationPlayer")
	animation_player.play("idle-loop")

func set_animation(animation):
	if animation == "run":
		switch_animation("run-loop")
	if animation == "run_punch":
		switch_animation("run_punch-loop")
	if animation == "walk":
		switch_animation("walk-loop")
	if animation == "attack":
		switch_animation("punch_heavy")
	if animation == "damage":
		switch_animation("damage")
	if animation == "idle":
		switch_animation("idle-loop")

func switch_animation(animation):
	if animation_player.current_animation != animation:
		animation_player.play(animation)