extends "res://Entities/Entity.gd"

@onready var collision := $Hitbox
@onready var hurt_box := $HurtBox
@onready var raycast := $RayCast2D
@onready var raycast_longer := $RayCastLonger
@onready var screen_notifier := $OnScreen

var hp := 3
var sprite_index : Dictionary = {&"roaming":0,&"attacking":1}
var current_state : StringName = &"roaming"
var previous_state : StringName
var change_states := true
var state_exceptions := []
var on_screen := false
var raycast_length := 250.0
var raycast_bonus_length := 0.0
var animate_change := false
var searching_speed := 325

signal killed

func _ready():
	super()
	
	add_to_group("enemy")
	screen_notifier.screen_entered.connect(on_screen_entered.bind(true))
	screen_notifier.screen_exited.connect(on_screen_entered.bind(false))
	change_state(current_state)
	animate_change = true

func on_screen_entered(p_value):
	on_screen = p_value

func change_state(new_state : String):
	if !change_states && !state_exceptions.has(new_state): return
	else: change_states = true
	previous_state = current_state
	current_state = new_state
	if sprite_index.has(current_state): sprite.frame = sprite_index[new_state]
	else: sprite.frame = 0
	if get_node_or_null("AnimationPlayer") != null && animate_change:
		if animation_player.has_animation(new_state): animation_player.play(new_state)
		else: animation_player.play("change_state")
	roaming = false
	
	match new_state:
		&"roaming":
			velocity = Vector2.ZERO
			randomize_roaming()
			roaming = true
			raycast_length = 250
		&"alert":
			var time := 0.5
			for enemy in get_tree().get_nodes_in_group("enemy"):
				if enemy.current_state == &"alert": time += 0.05
			var wait_timer = Global.new_timer(time)
			raycast_length = 500
			await wait_timer.timeout
			if new_state == &"alert": spotted_target()
		&"searching":
			make_path()
			if is_instance_valid(target) && target.is_in_group("item"): raycast_length = 50
			else: raycast_length = 400
		&"hurt":
			var hurt_timer = Global.new_timer(0.5)
			hurt_timer.timeout.connect(conditional_change.bind(previous_state,&"hurt"))
			if hp <= 0:
				change_state(&"death")
		&"trapped":
			velocity = Vector2(0,0)
			change_states = false
			state_exceptions = [&"hurt",&"death"]
		&"death":
			save_death()
			create_target()
			sprite.frame = sprite_index[&"hurt"]
			change_states = false
			state_exceptions = []
			collision.queue_free()
			var death_tween = create_tween()
			death_tween.tween_property(sprite,"modulate",Color(0,0,0,0),0.2)
			emit_signal(&"killed")
			await death_tween.finished
			queue_free()
		&"success":
			camera.target = self
			change_states = false
			state_exceptions = []
			stop_velocity()
			player.visible = false
			player.collision.queue_free()
			player.active = false
			player.get_node("Bat").queue_free()
			Global.entry_tag = 999
			camera.zoom_tween(Vector2(1.25,1.25),1.0)
			camera.rotate_tween(0.75, 0.2, true, true)
			if get_node_or_null("AnimationPlayer") != null && animation_player.has_animation(&"success"):
				await animation_player.animation_finished
				Global.fade_scene("save")
			else:
				var reload_timer = Global.new_timer(1.0)
				reload_timer.timeout.connect(Global.fade_scene.bind("save"))

func _process(delta):
	super(delta)
	
	var angle = abs((player.global_position - global_position).normalized().x)
	var angle_bonus = 0.2 - angle
	if angle_bonus > 0: angle += (angle_bonus*1.5)
	raycast.target_position.x = (angle * (raycast_length+raycast_bonus_length)) + 200
	
	if get_parent().get_node_or_null("Player") != null: 
		raycast.look_at(player.global_position)
		raycast_longer.look_at(player.global_position)
	
	match current_state:
		&"roaming":
			if is_instance_valid(raycast.get_collider()) && raycast.get_collider().is_in_group("player"):
				target = player
				change_state(&"alert")
			if on_screen && raycast_longer.is_colliding() && raycast_longer.get_collider().is_in_group("player"):
				raycast_bonus_length += 125.0 * delta
			elif raycast_bonus_length > 0: raycast_bonus_length -= 100.0 * delta
		&"alert":
			if get_parent().get_node_or_null("Player") != null: face_target(target)
			velocity = Vector2(0,0)
		&"searching":
			var next_path_pos = navigation_agent.get_next_path_position()
			var dir := global_position.direction_to(next_path_pos)
			velocity = dir * searching_speed
			
			if !is_instance_valid(target):
				change_state(&"roaming")
			if raycast.is_colliding() && raycast.get_collider().is_in_group("player"):
				target = player
				spotted_target()

func receive_damage(damage):
	hp -= damage
	change_state(&"hurt")

func pathfind_timeout():
	if current_state == &"searching": make_path()

func conditional_change(new_state,old_state):
	if current_state == old_state: change_state(new_state)

func kill_player(body):
	if body.is_in_group("player"):
		change_state(&"success")

func current_screen_status(value):
	if current_state == &"roaming": super(value)

func launcher_behaviour(facing):
	super(facing)
	change_state(&"launched")
	if sprite_index.has(&"hurt"): sprite.frame = sprite_index[&"hurt"]
	await finished_launch
	change_state(&"alert")

func spotted_target():
	pass

func hear_audio(_source):
	pass

func spotted_audio():
	pass

func in_water():
	if current_state == &"death": return
	change_state(&"death")
	super()
