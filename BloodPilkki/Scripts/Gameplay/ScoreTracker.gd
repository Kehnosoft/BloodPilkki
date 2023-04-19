extends Node

signal score_cap_hit

var scores = {}
var MAX_SCORE = 50

var _score_container = null

func _ready():
	print("Score module tracker added.")
	var level = get_parent()
	level.connect("score_added", Callable(self, "_on_score_added"))
	level.connect("player_added", Callable(self, "_on_player_added"))
	self.connect("score_cap_hit", Callable(level, "_on_score_cap_hit"))
	
	self._score_container = self.find_child("ScoreTrackerContainer")
	
func _on_player_added(player):
	scores[player.name] = 0
	
	var display_class = load("res://Prefabs/UI/PlayerScoreDisplay.tscn")
	var score_display = display_class.instantiate()
	self._score_container.add_child(score_display)
	score_display.set_name("%s_score_display" % player.name)
	score_display.init(player)

func _on_score_added(player, score):
    scores[player.name] += score
    print("%s gained %s score (current score: %s)" % [player.name, score, scores[player.name]])
    if scores[player.name] >= MAX_SCORE:
        emit_signal("score_cap_hit", scores)

func _get_player_score(player):
    for score in scores:
        if score[0] == player.name:
            return score
    return null