extends Spatial

var fishing_scene = load("res://Prefabs/Fishing.tscn")
var fish_on_scene = load("res://Prefabs/FishOn.tscn")
var fishing
var fish_on

func _ready():
	pass
	
func _fishing():
	if fishing == null:
		fishing = fishing_scene.instance()
		add_child(fishing)
	fishing.begin_fishing()
	
func _fish_on():
	if fish_on == null:
		fish_on = fish_on_scene.instance()
		add_child(fish_on)
	fish_on.strike()

func _process(delta):
	if Input.is_action_just_pressed("player_1_action"):
		_fishing()
		#_fish_on()
