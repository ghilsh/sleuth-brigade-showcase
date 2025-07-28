extends "res://Entities/NPCs/NPC.gd"

func _ready():
	super()
	expressions_index = {&"neutral":0,&"blink":2,&"stressed":3}
	
	if Global.plot > 2: position = Vector2(2611,604)
	if Global.plot < 2: roaming = false

func get_dialog():
	if Global.plot < 3: # INTRO
		dialog = &"HunterIntro"
		if spoken >= 2: dialog_tag = &"spokentwice"
		elif spoken >= 1: dialog_tag = &"spoken"
		elif Global.inventory != []: dialog_tag = &"beartrap"
	else:
		dialog = &"HunterCongrats" # NEXT ROOM
		if spoken >= 1: dialog_tag = &"spoken"
		else: dialog_tag = &"normal"
