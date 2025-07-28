extends "res://Entities/Entity.gd"

@export var spawn_anyway := false

@onready var squish_area := $SquishArea

func _ready():
	if randi_range(0,30) != 0 && !spawn_anyway: queue_free()
	roaming = true
	single_bob = false
	squish_area.body_entered.connect(squished)
	super()

func squished(body):
	if !body.is_in_group(&"entity"): return
	roaming = false
	animation_player.play(&"squish")
	await animation_player.animation_finished
	queue_free()
