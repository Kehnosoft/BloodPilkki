extends Spatial

var Types = load("res://Scripts/Types.gd")
var Utils = load("res://Scripts/Utils.gd")
var Items = load("res://Scripts/Items.gd")
var Debug_ui = null
var Ui = null
var Printer = null

var _game_state = Types.Game_states.LOADING
var _debugging = true
var _hole_respawn_timer = 0
var _respawn_timer = 0
var _highest_score = 0

var _players = []			# Array of competitors
var _holes = []				# Array of active holes in the ice
var _scores = []
var _spawners = []			# List of dead players

var _colors = [
	Color(1.0, 0.0, 0.0),
	Color(0.0, 1.0, 0.0),
	Color(0.0, 0.0, 1.0),
]

var RESPAWN_TIMER = 10
var HOLE_RESPAWN_TIMER = 10

func _ready():
	Ui = find_node("UI")
	Debug_ui = find_node("DebugUI")
	if _debugging:
		Debug_ui.show()
	else:
		Debug_ui.hide()
		
	Printer = Utils.Printer.new(Ui, _debugging, Debug_ui)
	Items = Items.Items.new()	# Init item tables
	_spawners = _get_player_spawners()
	_players = _init_players()
	_game_state = Types.Game_states.PLAYING
	Printer.print_message("Starting game with %d players and %d holes." % [len(_players), len(_holes)])
	if _debugging:
		var dev_hammer = Items.get_weapon("Dev hammer")
		var dev_player = _players[1]
		if dev_player:
			dev_player.give_weapon(dev_hammer)
	
func _process(delta):
	if self._game_state != Types.Game_states.ENDED and (_highest_score >= 100):
		_end_game()

func _physics_process(delta):
	if _respawn_timer >= RESPAWN_TIMER:
		_respawn_players()
		_respawn_timer = 0
	else:
		_respawn_timer += 0.1


##############
# Game state #
##############
func _end_game():
	_game_state = Types.Game_states.ENDED
	print("Game over")
	
func add_score(player_id, score_gain):
	var player_score = _get_score(player_id)
	if player_score:
		var score = clamp(player_score[1] + score_gain, 0.0, 100.0)
		player_score[1] = score
		if score > _highest_score:
			_highest_score = score
		print("Player %s scored %d points %s" % [player_id, score_gain, _scores])


###########
# Players #
###########	
func _init_players():
	var players = []
	for player in get_node("Players").get_children():
		player.set_player_id(len(players))
		player.set_player_color(_colors[len(players)])
		players.append(player)
		_scores.append([player.player_id, 0])
	return players
	
func _get_player_spawners():
	var spawners = []
	for spawner in get_node("Spawners").get_children():
		spawners.append(spawner)
	return spawners
	
func _get_available_player_spawners():
	var spawners = []
	for spawner in _spawners:
		if spawner.available:
			spawners.append(spawner)
	return spawners
	
func _get_player(player_id):
	for player in _players:
		if player[0] == player_id:
			return player
			
func _respawn_players():
	for spawner in _spawners:
		spawner.respawn_players()
	
func player_killed(player):
	var spawners = _get_available_player_spawners()
	if spawners:
		var spawner = spawners[randi() % len(spawners)]
		spawner.add_ghost(player)
		player.visible = false
		#Maybe spawn a decaying corpse?
	
	
#########
# Holes #	
#########	
func _get_holes():
	var holes = []
	for hole in get_node("Holes").get_children():
		holes.append(hole)
	return holes
	
func _get_score(player_id):
	for score in _scores:
		if score[0] == player_id:
			return score
	return null
	
		
############
# Plumbing #
############
func get_game_state():
	return _game_state
	
func get_players():
	return _players
	
func get_holes():
	return _holes
	
func get_scores():
	return _scores
	
func get_respawn_time():
	return _respawn_timer
	
func debugging_mode_active():
	return _debugging