extends Spatial

var _attack_indicator = null

func _ready():
	_attack_indicator = self.get_node("AttackIndicator")
	_attack_indicator.hide()
	
	self.connect("area_entered", self, "_on_attack_area_entered")
	self.connect("area_exited", self, "_on_attack_area_exit")
    
func _on_attack_area_entered(area):
	if "Fighter" in area.get_name():
		var target = area.get_parent()
		add_available_attack_target(target)
		print("%s entered the attack area %s" % [target.name, self.get_parent().name])
        
func _on_attack_area_exit(area):
	if "Fighter" in area.get_name():
		var target = area.get_parent()
		remove_available_attack_target(target)
		print("%s left the attack area of %s" % [target.name, self.get_parent().name])
		
func add_available_attack_target(target):
	var target_indicator = target.get_node("AttackIndicator")
	if target_indicator:
		target_indicator.show()
	get_parent()._available_attack_targets.append(target)

func remove_available_attack_target(target):
	var targets = get_parent()._available_attack_targets
	for i in range(0, len(targets)):
		if targets[i] == target:
			get_parent()._available_attack_targets.remove(i)
			var target_indicator = target.get_node("AttackIndicator")
			if target_indicator:
				target_indicator.hide()