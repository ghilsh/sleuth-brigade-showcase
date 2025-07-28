extends "res://Entities/NPCs/NPC.gd"

func _ready():
	super()
	expressions_index = {&"neutral":0,&"blink":2,&"scared":3}

func get_dialog():
	dialog = &"DougPlaceholder"
