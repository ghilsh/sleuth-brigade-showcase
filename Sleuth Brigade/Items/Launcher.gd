extends "res://Items/Item.gd"

@export var default_facing := Vector2(1,0)

@onready var launch_area := $LaunchArea
@onready var anim_player := $AnimationPlayer

var active_launchers := []

func set_facing():
	match facing:
		Vector2(1,0): sprite.rotation_degrees = 0
		Vector2(-1,0): sprite.rotation_degrees = 180
		Vector2(0,1): sprite.rotation_degrees = 90
		Vector2(0,-1): sprite.rotation_degrees = 270

func _ready():
	super()
	launch_area.body_entered.connect(launch_entity)
	if facing == Vector2.ZERO: facing = default_facing
	if placed: global_position += facing * 30
	set_facing()

func launch_entity(entity):
	if entity.is_in_group("entity") && !active_launchers.has(entity) && pickupable:
		anim_player.stop()
		anim_player.play(&"bounce")
		entity.launcher_behaviour(facing)
		destroy()

func destroy():
	pickupable = false
	sprite.frame = 1
	var timer = Global.new_timer(1)
	$Break.play()
	
	await timer.timeout
	
	var tween = create_tween()
	tween.tween_property(sprite,"modulate",Color(1,1,1,0),0.5)
	
	await tween.finished
	
	queue_free()
