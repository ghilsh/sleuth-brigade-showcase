extends "res://Entities/NPCs/NPC.gd"

func get_dialog():
	dialog = &"Smoker"
	if spoken > 0: dialog_tag = &"spoken"
