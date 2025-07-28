extends Area2D

@export_file var destination
@export var tag : int

func _ready():
	body_entered.connect(on_entered)
	
func on_entered(body):
	if body.is_in_group("player"):
		Global.entry_tag = tag
		Global.change_scene(destination)
