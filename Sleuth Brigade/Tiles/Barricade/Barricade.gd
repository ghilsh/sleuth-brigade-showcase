extends StaticBody2D

@onready var animation_player := $AnimationPlayer

@export var tag := 0

func _ready():
	add_to_group("barricade")

func open(called_tag):
	if called_tag != tag: return
	animation_player.play("open")
	await animation_player.animation_finished
	queue_free()
