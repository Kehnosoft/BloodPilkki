extends Node

signal score_cap_hit

var scores = {}
var MAX_SCORE = 50

func _ready():
	print("Score module tracker added.")
	var level = get_parent()
	level.connect("score_added", self, "_on_score_added")
	level.connect("player_added", self, "_on_player_added")
	self.connect("score_cap_hit", level, "_on_score_cap_hit")
	
func _on_player_added(player):
	scores[player.name] = 0

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