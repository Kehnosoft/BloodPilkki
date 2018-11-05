extends Spatial

var _attack_indicator = null
var _available_attack_targets = []

func _ready():
	_attack_indicator = self.get_node("AttackIndicator")
	hide_attack_indicator()
	
	self.connect("area_entered", self, "_on_attack_area_entered")
	self.connect("area_exited", self, "_on_attack_area_exit")
    
func _on_attack_area_entered(area):
	if "Fighter" in area.get_name():
		var player = area.get_parent()
		add_available_attack_target(self)
		print("%s entered the attack area %s" % [player.name, self.get_parent().name])
        
func _on_attack_area_exit(area):
	if "Fighter" in area.get_name():
		var player = area.get_parent()
		remove_available_attack_target(self)
		print("%s left the attack area of %s" % [player.name, self.get_parent().name])
		
func show_attack_indicator():
	if _attack_indicator:
			_attack_indicator.show()
			
func hide_attack_indicator():
	if _attack_indicator:
		_attack_indicator.hide()
		
func add_available_attack_target(target):
	if len(_available_attack_targets) > 0:
		return
	target.show_attack_indicator()
	_available_attack_targets.append(target)

func remove_available_attack_target(target):
	for i in range(0, len(_available_attack_targets)):
		if _available_attack_targets[i] == target:
			_available_attack_targets.remove(i)
			target.hide_attack_indicator()