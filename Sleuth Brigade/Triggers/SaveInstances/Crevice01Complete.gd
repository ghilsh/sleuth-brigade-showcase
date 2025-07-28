extends "res://Triggers/SavePoint.gd"

func create_save(body):
	var save := false
	if Global.dead_index.has("res://Screens/Rooms/RoomCrevice01.tscn"):
		for pos in Global.dead_index["res://Screens/Rooms/RoomCrevice01.tscn"]:
			if pos[0] >= 1000.0:
				save = true
	
	if save && body.is_in_group("player"): 
		super(body)
