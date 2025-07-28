extends Node2D

@onready var background : NinePatchRect = $Background
@onready var sprite : Sprite2D = $Sprite

@export var slot : int = 0

var empty : bool = false

func match_sprite():
	if Global.inventory.size() > slot:
		var current_item = Global.inventory[slot]
		if !Global.items_index.has(current_item):
			current_item = &"null"
		var new_texture = Global.items_index.get(current_item)[1]
		sprite.set_texture(new_texture)
		sprite.hframes = Global.items_index.get(current_item)[2]
		empty = false
	else:
		empty = true
		sprite.set_texture(null)
	
	if empty: background.modulate = "ababab" # shaded
	elif slot == Global.current_slot: background.modulate = "ffff00" # yellow
	else: background.modulate = "ffffff" # normal

func _ready():
	add_to_group("item_slots")
	match_sprite()
