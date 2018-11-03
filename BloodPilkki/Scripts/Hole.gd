extends "res://Scripts/Interactable.gd"

var Types = load("res://Scripts/Types.gd")
var Strings = load("res://Scripts/Strings.gd")

var level = null
var id = null
var lifetime = 0

# Fish type and score
var fish_table = [
	[Types.Fish.BOOT, 0],
	[Types.Fish.TROUT, 10],
	[Types.Fish.SALMON, 25]
]

func _ready():
	level = get_owner()
	lifetime = 0
	name = get_name()

func action_performed():
	_begin_fishing(_actor)
	
func _begin_fishing(fisher):
	var loot = fish_table[randi() % len(fish_table)]
	print("%s began fishing for %s" % [fisher.name, loot[1]])
	# Todo: minigame
	_fish(fisher, loot)
	
func _fish(fisher, loot):
	var msg = "%s fished %s (%d points)" % [fisher.name, Strings.fish(loot[0]), loot[1]]
	print(msg)
	level.printer.print_message(msg)
	level.add_score(fisher.player_id, loot[1])