class Weapon:
	var id = 0
	var name = "Weapon"
	var min_damage = 0.0
	var max_damage = 0.0
	
	func _init(id=0, name="", min_damage=0.0, max_damage=0.0, kwargs=[]):
		self.id = id
		self.name = name
		
		self.min_damage = min_damage
		if max_damage == 0:
			max_damage = min_damage
		else:
			max_damage = max_damage
		
		for kwarg in kwargs:
			if self.hasattr(kwarg):
				print(kwarg)