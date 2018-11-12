class Items:
	var Weapons = load("res://Scripts/Weapon.gd")
	
	var _weapons = []

	func _init():
		var dev_hammer = Weapons.Weapon.new(-1, "Dev hammer", 100000.0)
		_weapons.append(dev_hammer)

	func get_weapon(id):
		for weapon in _weapons:
			if typeof(id) == TYPE_INT and weapon.id == id:
				return weapon
			if typeof(id) == TYPE_STRING and weapon.name == id:
				return weapon