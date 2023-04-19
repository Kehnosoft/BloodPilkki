extends Node3D

var available = false

var _ghosts = []

func _ready():
	available = true

func add_ghost(player):
	_ghosts.append(player)
	player.position = self.position
	available = false

func respawn_players():
	for player in _ghosts:
		player.respawn()
		if not player.visible:
			player.visible = true
	available = true
