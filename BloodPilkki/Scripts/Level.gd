extends Spatial

var Types = load("res://Scripts/Types.gd")
var Utils = load("res://Scripts/Utils.gd")
var game_state = Types.Game_states.LOADING

var debug = true
var debug_ui = null
var ui = null
var printer = null

var players = []			# Array of competitors
var holes = []				# Array of active holes in the ice
var scores = []
var highest_score = 0

func _ready():
	ui = find_node("UI")
	debug_ui = find_node("DebugUI")
	if debug:
		debug_ui.show()
	else:
		debug_ui.hide()
		
	printer = Utils.Printer.new(ui, debug, debug_ui)
	players = _init_players()
	game_state = Types.Game_states.PLAYING
	printer.print_message("Starting game with %d players and %d holes." % [len(players), len(holes)])
	
func _process(delta):
	if game_state != Types.Game_states.ENDED and (highest_score >= 100):
		_end_game()
		
# Some debug and timer shits for _physics_process
var _score_bleed_timer = 1
var _score_bleed_elapsed_secs = 0
var _fatigue_timer = 1
var _fatigue_elapsed_secs = 0

func _physics_process(delta):
	pass
		
func _end_game():
	game_state = Types.Game_states.ENDED
	print("Game over")
	
func _init_players():
	var players = []
	for player in get_node("Players").get_children():
		var id = 1 + len(players)
		player.player_id = id
		players.append([id, player])
		scores.append([id, 0])
	return players
	
func _get_player(player_id):
	for player in players:
		if player[0] == player_id:
			return player
	
func _get_holes():
	var holes = []
	for hole in get_node("Holes").get_children():
		holes.append(hole)
	return holes
	
func _get_score(player_id):
	for score in scores:
		if score[0] == player_id:
			return score
	return null
	
func add_score(player_id, score_gain):
	var player_score = _get_score(player_id)
	if player_score:
		var score = clamp(player_score[1] + score_gain, 0.0, 100.0)
		player_score[1] = score
		if score > highest_score:
			highest_score = score
		print("Player %s scored %d points %s" % [player_id, score_gain, scores])