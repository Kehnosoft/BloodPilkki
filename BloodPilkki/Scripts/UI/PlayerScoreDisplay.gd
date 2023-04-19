extends HSplitContainer

var player = null
var player_name = "Player X"
var player_score = 0

var _player_name_label = null
var _player_score_label = null

func _ready():
	var level = get_tree().get_root().get_node("Root")
	level.connect("score_added", Callable(self, "_on_score_added"))
	self._player_name_label = self.get_child(0)
	self._player_score_label = self.get_child(1)
	
func init(player):
	self.player = player
	self.player_name = player.name
	self.player_score = 0
	self._update_ui(true)
	
func _update_ui(refresh_name=false):
	if refresh_name:
		self._player_name_label.set_text(self.player_name)
	self._player_score_label.set_text("%s" % self.player_score)

func _on_score_added(player, score):
	if player != self.player:
		return
	
	self.player_score += score
	self._update_ui()