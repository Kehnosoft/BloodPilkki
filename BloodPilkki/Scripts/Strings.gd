var Types = load("res://Scripts/Types.gd")

static func game_state(current_game_state):
	# How the fuck do I use enum values as dict keys?
	var strings = {
		0: "In menu",		# Types.Game_states.IN_MENU
		1: "Playing",		# Types.Game_states.PLAYING
		2: "Paused",		# Types.Game_states.PAUSED
		3: "Game ended",	# Types.Game_states.END
		4: "Loading",		# Types.Game_states.LOADING
		5: "Score screen"	# Types.Game_states.SCORE_SCREEN
	}
	return strings.get(current_game_state, "Unknown")
	
static func fish(fish):
	var strings = {
		0: "Boot",
		1: "Trout",
		2: "Salmon",
	}
	return strings.get(fish, "Unknown")
