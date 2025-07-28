extends "res://Screens/Rooms/Room.gd"

func _ready():
	super()
	var delete := false
	if Global.dead_index.has("res://Screens/Rooms/RoomCrevice02.tscn"):
		for pos in Global.dead_index["res://Screens/Rooms/RoomCrevice02.tscn"]:
			if pos[0] >= 5475: delete = true
	if delete:
		tile_map.set_cell(3,Vector2i(85,9))
