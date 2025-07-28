extends "res://Screens/Rooms/Room.gd"

func _ready():
	if Global.plot < 2: change_default_music(&"none")
	super()
