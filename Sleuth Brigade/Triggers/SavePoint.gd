extends Area2D

@export var entry_tag : int

func _ready():
	body_entered.connect(create_save)

func create_save(body):
	if body.is_in_group("player"):
		Global.entry_tag = entry_tag
		Global.create_save()
