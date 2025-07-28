extends "res://Items/Item.gd"

@export var item_pool : Array[StringName] = [&"null"]

func collect_item():
	var rand = randi_range(0,(item_pool.size()-1))
	actual_name = item_pool[rand]
	super()
