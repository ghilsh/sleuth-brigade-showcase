extends Node2D

@export var amount := 1
@export var direction := Vector2(1,0)
@export var delay := 0.0

@onready var cone_scene := preload("res://Tiles/Cone/Cone.tscn")
@onready var sprite := $Sprite

var amount_spawned := 0

func _ready():
	sprite.visible = false
	add_to_group(&"conespawners")

func spawn_cones():
	if amount_spawned == 0 && delay != 0.0:
		var delay_timer = Global.new_timer(delay)
		await delay_timer.timeout
	
	if amount > amount_spawned:
		var cone = cone_scene.instantiate()
		cone.add_to_group(&"cone")
		cone.global_position = global_position + (direction*64*amount_spawned)
		if direction.x != 0: cone.get_node("CollisionShape2D").rotation_degrees = 90
#		if amount_spawned == 0: cone.get_node("CollisionShape2D").shape.size += Vector2(0,1) * 30
		get_tree().current_scene.add_child.call_deferred(cone)
		amount_spawned += 1
		var timer = Global.new_timer(0.1)
		await timer.timeout
		spawn_cones()
