extends "res://Cutscenes/Cutscene.gd"

@export var hunter : CharacterBody2D

func initiate_cutscene():
	Global.plot += 1
	var start_timer = Global.new_timer(0.5)
	var action_timer = Global.new_timer(1.5)
	hunter.sprite.flip_h = false
	
	await start_timer.timeout
	
	hunter.hitbox.disabled = true
	hunter.modulate = Color(1,1,1,0)
	hunter.position = Vector2(860,100)
	camera.position_smoothing_speed = 2.5
	camera.target = hunter
	camera.zoom_tween(Vector2(1.2,1.2),1.0)
	
	await action_timer.timeout
	
	var tween = create_tween()
	tween.tween_property(hunter,"modulate",Color(1,1,1),0.5)
	hunter.sprite.flip_h = false
	camera.position_smoothing_speed = 10
	hunter.velocity = Vector2(0,300)
	hunter.roaming = false
	hunter.expression = &"stressed"
	var stop_timer = Global.new_timer(0.75)
	
	await stop_timer.timeout
	hunter.stop_velocity()
	await hunter.velocity_stopped
	hunter.animation_player.play(&"sigh")
	await hunter.animation_player.animation_finished
	hunter.animation_player.play(&"oi")
	await hunter.animation_player.animation_finished
	
	hunter.roaming = true
	hunter.expression = &"neutral"
	hunter.hitbox.disabled = false
	player.active = true
	camera.back_to_default()
	Radio.change_stream(&"music",&"forest")
	get_tree().call_group(&"room",&"change_default_music",&"forest")
	queue_free()

func _ready():
	super()
	if Global.plot == 1: 
		hunter.roaming = false
		hunter.position = Vector2(9999,9999)
