extends "res://Entities/Enemies/Enemy.gd"

@onready var tile_detector := $TileDetector
@onready var shape_cast := $ShapeCast2D
@onready var broken_icicle_scene := preload("res://Tiles/BrokenIcicle/BrokenIcicle.tscn")

var attacking_speed : float
var max_speed : float = 100.0
var move_direction : Vector2
var overlapping_tiles := false
var shapecast_follow := false
var success_bumped := false

const INITSPEED = 2000.0
const FRICTION = 1800.0

func _ready():
	super()
	sprite_index = {&"roaming":0,&"alert":1,&"searching":1,&"attacking":2,&"trapped":3,&"hurt":4,&"bump":4}
	single_bob = false
	roam_parameters = [400,700]
	searching_speed = 500

func _process(delta):
	super(delta)
	
	if shapecast_follow && target != null: shape_cast.target_position = target.global_position - global_position
	match current_state:
		&"searching":
			if velocity.x >= 0: sprite.flip_h = false
			else: sprite.flip_h = true
		&"attacking":
			velocity = move_direction * attacking_speed
			attacking_speed -= FRICTION * delta
			if attacking_speed <= 0: change_state(&"roaming")
			process_bump_behaviour()
			
			if velocity.x < 0: sprite.flip_h = true
			else: sprite.flip_h = false
		&"bump":
			if velocity.x > 0: sprite.flip_h = true
			else: sprite.flip_h = false
		&"success":
			for i in get_slide_collision_count():
				var collision_detected = get_slide_collision(i)
				print(get_slide_collision_count())
				if get_slide_collision_count() != 0 && (collision_detected.get_collider().name == &"TileMap" or collision_detected.get_collider().is_in_group("enemy")) && !success_bumped:
					@warning_ignore("narrowing_conversion")
					var angle : int = rad_to_deg(collision_detected.get_angle())
					if angle == 90: velocity.x *= -1
					else: velocity.y *= -1
					velocity *= 0.5
					stop_velocity()
					success_bumped = true
					var false_timer = Global.new_timer(0.05)
					await false_timer.timeout
					success_bumped = false
					print(collision_detected.get_collider())

func change_state(new_state : String):
	shapecast_follow = false
	if current_state == &"attacking": hurt_box.body_entered.disconnect(kill_player)
	super(new_state)
	match new_state:
		&"alert": shapecast_follow = true
		&"searching":
			shapecast_follow = true
			animation_player.play(&"searching")
		&"attacking":
			attacking_speed = INITSPEED
			if is_instance_valid(target): move_direction = (target.position - position).normalized()
			hurt_box.body_entered.connect(kill_player)
			for body in hurt_box.get_overlapping_bodies(): if body.is_in_group("player"): kill_player(body)
			$Audio/Swoosh.play()
		&"bump":
			$Audio/Smash.play()
			stop_velocity() 
			await velocity_stopped
			conditional_change(&"searching",&"bump")

func spotted_target():
	if raycast.is_colliding() && target != null:
		if raycast.get_collider() == target && is_instance_valid(shape_cast.get_collider(0)) && shape_cast.get_collider(0) == target:
			change_state(&"attacking")
		else: change_state(&"searching")

func hear_audio(source):
	change_state(&"alert")
	target = source

func spotted_audio():
	change_state(&"attacking")

func process_bump_behaviour():
	for i in get_slide_collision_count():
		var collision_detected = get_slide_collision(i)
		if collision_detected.get_collider().name == &"TileMap":# or collision_detected.get_collider().is_in_group("enemy"):
			@warning_ignore("narrowing_conversion")
			var angle : int = rad_to_deg(collision_detected.get_angle())
			if angle == 90: velocity.x *= -1
			else: velocity.y *= -1
			velocity *= 0.2
			change_state(&"bump")
			if collision_detected.get_collider().name == &"TileMap": 
				var tile_map : TileMap = collision_detected.get_collider()
				var navigation_tiles = get_tree().current_scene.get_node("Navigation")
				var offset = velocity.normalized() * 2
				var pos : Vector2i = tile_map.local_to_map(collision_detected.get_position()-offset)
				var id : int
				for e in tile_map.get_layers_count(): if tile_map.get_layer_name(e) == "icicles": id = e
				var data = tile_map.get_cell_tile_data(id,pos)
				if data && data.get_custom_data("Terrain") == "icicle":
					tile_map.set_cell(id,pos)
					navigation_tiles.set_cell(-1,pos)
					get_tree().current_scene.get_node("NavigationRegion2D").bake_navigation_polygon()
					var actual_pos = pos*64
					var broken_icicle = broken_icicle_scene.instantiate()
					broken_icicle.global_position = actual_pos
					broken_icicle.movement_direction = -velocity.normalized()
					get_tree().current_scene.add_child(broken_icicle)
			return

func cant_reach_target():
	change_state(&"attacking")
