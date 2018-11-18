extends Spatial

signal fishing_complete(result)

func _ready():
	randomize()
	
func begin_fishing():
	print ("Begin fishing.")
	fishing_complete()
	
func fishing_complete():
	emit_signal("fishing_complete", true)
