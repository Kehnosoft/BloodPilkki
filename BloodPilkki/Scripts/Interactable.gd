extends Spatial

var ACTION_TIME = 0.0
var _actor = null
var player_in_area = false
var _interaction_indicator = null

func _ready():
	_interaction_indicator = self.get_node("InteractionIndicator")
	hide_action_indicator()
	
	get_node("InteractionArea").connect("area_entered", self, "_on_interaction_area_entered")
	get_node("InteractionArea").connect("area_exited", self, "_on_interaction_area_exit")
    
func _on_interaction_area_entered(area):
	if "Player" in area.get_name() and not _actor:
		var player = area.get_parent()
		player_in_area = true
		player.add_available_action(self)
		_actor = player
		print("%s entered the interaction area" % player.name)
        
func _on_interaction_area_exit(area):
	if "Player" in area.get_name():
		var player = area.get_parent()
		if player == _actor:
			player_in_area = false
			player.remove_available_action(self)
			_actor = null
			print("%s left the interaction area" % player.name)
		
func show_action_indicator():
	if _interaction_indicator:
			_interaction_indicator.show()
			
func hide_action_indicator():
	if _interaction_indicator:
		_interaction_indicator.hide()
	
func action_performed():
	pass