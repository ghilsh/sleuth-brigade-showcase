extends CharacterBody2D

@onready var player : CharacterBody2D
@onready var camera : Camera2D
@onready var sprite
@onready var init_height
@onready var animation_player : AnimationPlayer
@onready var terrain_detector_scene := preload("res://Entities/TerrainDetector.tscn")
@onready var navigation_agent : NavigationAgent2D
@onready var splash_scene := preload("res://Entities/Splash.tscn")
@onready var target_scene := preload("res://Entities/Target.tscn")

var from_orgin := Vector2.ZERO
var terrain_detector : Area2D
var jump_height := 10
var velocity_stopping : Vector2
var actual_name : String
var knockback_direction := Vector2(0,0)
var velocity_tweeners := []
var airborne := false:
	set(value):
		airborne = value
		if value == false && terrain_detector.terrain_mask == &"water": in_water()
var target:
	set(value):
		target = value
		if value == null:
			target_null()

var stopping_velocity := false
var roaming := false
var roam_parameters := [60,480]:
	set(value):
		roam_parameters = value
		randomize_roaming()
var init_randomized := false
var init_pos : Vector2

var expressions_index := {&"neutral":0}
var back_index := {&"neutral":1}
var expression := &"neutral":
	set(value):
		expression = value
		if sprite.frame != 1: sprite.frame = expressions_index[expression]

var terrain : String:
	set(value):
		terrain = value
		change_footsteps()

var animate_bob := false
var single_bob := true
var finished_bob := true
@onready var bob_timer := 0.6:
	set(value):
		bob_timer = value
		if bob_timer <= 0.0: 
			initiate_roaming()
var animating_bob := false
var back_sprite := false

const KNOCKBACKFRICTION = 90

signal velocity_stopped
signal finished_launch

func bob_animation(forced = false):
	if finished_bob or forced:
		var get_sprite = sprite
		if get_node_or_null("SpritePivot") != null: get_sprite = get_node("SpritePivot")
		var bob_tween = create_tween()
		finished_bob = false
		bob_tween.tween_property(get_sprite, "position", Vector2(get_sprite.position.x,init_height-jump_height), 0.1).set_ease(Tween.EASE_OUT)
		bob_tween.tween_property(get_sprite, "position", Vector2(get_sprite.position.x,init_height), 0.1).set_ease(Tween.EASE_IN)
		
		await bob_tween.finished
		
		if single_bob && roaming: terrain_detector.footsteps.play()
		finished_bob = true
		ended_bob()

func initiate_roaming(): # from_orgin
	randomize_roaming()
	
	var rand_axis = randi_range(0,1)
	var rand_direction = randi_range(0,1)
	if rand_direction == 0: rand_direction = -1
	
	var new_distance := from_orgin
	if rand_axis == 0: new_distance.x = from_orgin.x + rand_direction
	else: new_distance.y = from_orgin.y + rand_direction
	if (abs(new_distance.x) > 1) or (abs(new_distance.y) > 1):
		initiate_roaming()
		return
	else: from_orgin = new_distance
	
	if rand_axis == 0: velocity.x = rand_direction * 50
	else: velocity.y = rand_direction * 50
	
	if velocity.x < 0: sprite.flip_h = true
	elif velocity.x > 0: sprite.flip_h = false
	
	stop_velocity()
	if single_bob or animate_bob: bob_animation()

func handle_animation():
	if back_sprite && (velocity != Vector2(0,0) or roaming):
		if velocity.y >= 0: sprite.frame = expressions_index[expression]
		elif sprite.hframes >= 2: sprite.frame = 1

func _ready():
	init_pos = global_position
	if get_node_or_null("Sprite") != null: 
		sprite = get_node("Sprite")
		init_height = sprite.position.y
	else: 
		sprite = get_node("SpritePivot/Sprite")
		init_height = get_node("SpritePivot").position.y
		
	add_to_group("entity")
	randomize_roaming()
	bob_timer /= 4
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	if get_node_or_null("AnimationPlayer") != null: animation_player = $AnimationPlayer
	
	actual_name = name
	for character in [" ","1","2","3","4","5","6","7","8","9"]:
		actual_name = actual_name.replace(character,"")
	player = Global.get_player()
	
	if single_bob:
		terrain_detector = terrain_detector_scene.instantiate()
		add_child(terrain_detector)

func _process(delta):
	if velocity != Vector2.ZERO: move_and_slide()
	if roaming && init_randomized: bob_timer -= delta
	if animate_bob && velocity != Vector2(0,0) && finished_bob && !roaming: bob_animation()
	if stopping_velocity: velocity = velocity_stopping
	
	if animate_bob && !roaming:
		if velocity != Vector2.ZERO && !terrain_detector.footsteps.playing: terrain_detector.footsteps.play()
		elif velocity == Vector2.ZERO && terrain_detector.footsteps.playing: terrain_detector.footsteps.stop()
	
	knockback_direction.x = move_toward(knockback_direction.x, 0, KNOCKBACKFRICTION*delta)
	knockback_direction.y = move_toward(knockback_direction.y, 0, KNOCKBACKFRICTION*delta)

func randomize_roaming():
	var new_timer : float = randi_range(roam_parameters[0],roam_parameters[1])
	bob_timer = new_timer / 100
	init_randomized = true

func stop_velocity(time := 0.5):
	if velocity_tweeners != []:
		for tween in velocity_tweeners:
			tween.kill()
	var tween = create_tween()
	velocity_tweeners.append(tween)
	velocity_stopping = velocity
	tween.tween_property(self, "velocity_stopping", Vector2(0,0), time)
	stopping_velocity = true
	
	await tween.finished
	
	if stopping_velocity: # stops it from leaving velocity as a really small integer value 1/3 of times
		velocity = Vector2(0,0)
		stopping_velocity = false
	emit_signal(&"velocity_stopped")

func face_target(target_node):
	if is_instance_valid(target_node) && position.x > target_node.position.x: sprite.flip_h = true
	else: sprite.flip_h = false
	if back_sprite:
		if position.y < (target_node.position.y + 20): sprite.frame = expressions_index[expression]
		elif sprite.hframes >= 2: sprite.frame = 1

func change_footsteps():
	var new_path = "res://Assets/Audio/Sounds/Footsteps/snd_footstep_"+terrain+".ogg"
	if ResourceLoader.exists(new_path): 
		var new_stream : Resource = load(new_path)
		terrain_detector.footsteps.stream = new_stream
		terrain_detector.footsteps.play()

func set_values(): # needs to be called in camera after it's ready
	if get_tree().get_nodes_in_group("camera") != []:
		camera = get_tree().get_nodes_in_group("camera")[0]
	player = Global.get_player()

func create_nav_agent():
	navigation_agent = NavigationAgent2D.new()
	navigation_agent.name = "NavigationAgent2D"
	navigation_agent.path_desired_distance = 15
	navigation_agent.path_postprocessing = NavigationPathQueryParameters2D.PATH_POSTPROCESSING_EDGECENTERED
	navigation_agent.radius = 175
	add_child(navigation_agent)

func make_path():
	if get_node_or_null("NavigationAgent2D") == null: create_nav_agent()
	if is_instance_valid(target):
		navigation_agent.target_position = target.global_position
		if !navigation_agent.is_target_reachable(): cant_reach_target()
	var path_timer = Global.new_timer(0.5)
	await path_timer.timeout
	pathfind_timeout()

func pathfind_timeout():
	make_path()

func cant_reach_target():
	pass

func launcher_behaviour(facing):
	airborne = true
	var jump_tween := create_tween()
	var prev_anim = animate_bob
	var get_sprite = sprite
	if get_node_or_null("SpritePivot") != null: get_sprite = get_node("SpritePivot")
	var entity_height = get_sprite.position.y
	jump_tween.tween_property(get_sprite, "position", Vector2(get_sprite.position.x,entity_height-(jump_height*7.5)), 0.1).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(get_sprite, "position", Vector2(get_sprite.position.x,init_height), 0.2).set_ease(Tween.EASE_IN)
	velocity = facing * 1500
	stop_velocity()
	animate_bob = false
	
	await jump_tween.finished
	
	animate_bob = prev_anim
	airborne = false
	emit_signal(&"finished_launch")

func in_water():
	var splash = splash_scene.instantiate()
	splash.global_position = global_position
	if splash == null: splash.get_node("AnimationPlayer").animation_finished.connect(queue_free)
	get_tree().current_scene.add_child(splash)
	velocity = Vector2.ZERO
	visible = false

func ended_bob():
	pass

func current_screen_status(value):
	if value: process_mode = Node.PROCESS_MODE_INHERIT
	else: process_mode = Node.PROCESS_MODE_DISABLED

func save_death(value = true):
	var snapped_pos := [snapped(init_pos.x,0.01),snapped(init_pos.y,0.01)]
	var scene_name = get_tree().current_scene.scene_file_path
	if value:
		if !Global.dead_index.has(scene_name):
			Global.dead_index[scene_name] = []
		Global.dead_index[scene_name].append(snapped_pos)
	elif Global.dead_index.has(scene_name) && Global.dead_index[scene_name].has(snapped_pos):
		Global.dead_index[scene_name].erase(snapped_pos) # global_position

func save_place(value = true):
	var snapped_pos = [snapped(global_position.x,0.01),snapped(global_position.y,0.01)]
	var scene_name = get_tree().current_scene.scene_file_path
	if value:
		if !Global.remember_index.has(scene_name): Global.remember_index[scene_name] = []
		var accounted := false
		for entry in Global.remember_index[scene_name]:
			if entry[1] == snapped_pos: accounted = true
		if !accounted: Global.remember_index[scene_name].append([actual_name,snapped_pos])
			
	elif Global.remember_index.has(scene_name): #&& Global.remember_index[scene_name].has([actual_name,[snapped_pos[0],snapped_pos[1]]]):
		for entry in Global.remember_index[scene_name]:
			if (entry[0] == actual_name) && ( snapped(entry[1][0],0.01) == snapped(snapped_pos[0],0.01) ) && ( snapped(entry[1][1],0.01) == snapped(snapped_pos[1],0.01) ):
				Global.remember_index[scene_name].erase(entry)

func target_null():
	pass

func create_target():
	var new_target := target_scene.instantiate()
	get_parent().call_deferred(&"add_child",new_target)
	new_target.global_position = global_position
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.target == self:
			enemy.target = new_target
			enemy.current_state = &"searching"
