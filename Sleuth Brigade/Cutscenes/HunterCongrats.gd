extends "res://Cutscenes/Cutscene.gd"

@export var hunter : CharacterBody2D
@onready var enemy_scene := preload("res://Entities/Enemies/Meatball/Meatball.tscn")

func initiate_cutscene():
	var alt := true
	if !Global.dead_index.is_empty():
		for pos in Global.dead_index["res://Screens/Rooms/RoomCrevice01.tscn"]:
			if pos[0] >= 1000: alt = false
	if alt:
		alt_cutscene()
		return
	Global.plot += 1
	hunter.roaming = false
	hunter.velocity = Vector2.ZERO
	var start_timer = Global.new_timer(0.5)
	var action_timer = Global.new_timer(1.5)
	
	await start_timer.timeout
	
	hunter.hitbox.disabled = true
	hunter.modulate = Color(1,1,1,0)
	teleport_entity(hunter,Vector2(2600,90))
	camera.position_smoothing_speed = 2.5
	camera.target = hunter
	
	await action_timer.timeout
	
	var tween = create_tween()
	hunter.face_target(player)
	Global.player_facing.y = -1
	tween.tween_property(hunter,"modulate",Color(1,1,1),0.5)
	camera.position_smoothing_speed = 10
	hunter.velocity = Vector2(0,300)
	hunter.roaming = false
	var stop_timer = Global.new_timer(0.2)
	
	await stop_timer.timeout
	
	hunter.stop_velocity()
	
	await hunter.velocity_stopped
	
	var textbox = Global.create_textbox("HunterCongrats","cutscene")
	
	await textbox.queue_ended
	
	Global.player_facing.y = 1
	hunter.roaming = true
	hunter.hitbox.disabled = false
	player.active = true
	camera.back_to_default()
	Global.create_save()
	queue_free()
 
func alt_cutscene():
	var enemy = enemy_scene.instantiate()
	
	var start_timer = Global.new_timer(0.5)
	var action_timer = Global.new_timer(1.5)
	var hitbox_timer = Global.new_timer(1.6)
	
	await start_timer.timeout
	
	get_tree().current_scene.add_child(enemy)
	enemy.roaming = false
	enemy.change_state(&"nothing")
	enemy.target = player
	enemy.change_states = false
	enemy.collision.disabled = true
	enemy.modulate = Color(1,1,1,0)
	enemy.set_values()
	teleport_entity(enemy,Vector2(2600,90))
	camera.position_smoothing_speed = 2.5
	camera.target = enemy
	
	await action_timer.timeout
	
	enemy.state_exceptions = [&"attacking",&"success"]
	enemy.change_state(&"attacking")
	var tween = create_tween()
	tween.tween_property(enemy,"modulate",Color(1,1,1),0.1)
	camera.position_smoothing_speed = 10
	
	await hitbox_timer.timeout
	
	enemy.collision.disabled = false
