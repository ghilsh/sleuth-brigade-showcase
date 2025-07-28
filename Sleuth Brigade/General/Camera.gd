extends Camera2D

@onready var player := $"../Player"

var target : CharacterBody2D
var follow_target := true
var cam_offset := Vector2.ZERO
var zooming := false
var rotating := false

func back_to_default():
	target = player
	position = target.position
	set_deferred("position_smoothing_enabled",true)
	set_deferred("position_smoothing_speed",7)
	if zoom != Vector2(1,1): zoom_tween(Vector2(1,1))

func _ready():
	set_param()
	add_to_group("camera")
	get_tree().call_group("entity","set_values")
	back_to_default()
	if (limit_bottom - limit_top) != 648: 
		offset.y = -50
	ignore_rotation = false
	limit_smoothed = true
	zoom = Global.debug_zoom

func set_param():
	if get_parent().get_node_or_null("CameraParam") != null:
		for param in get_parent().get_node("CameraParam").get_children():
			var map_limits = param.get_global_rect()
			if player.position.x > map_limits.position.x && player.position.x < map_limits.end.x:
				if player.position.y > map_limits.position.y && player.position.y < map_limits.end.y:
					get_param(param)

func get_param(param):
	position_smoothing_enabled = false
	var map_limits = param.get_global_rect()
	limit_left = map_limits.position.x
	limit_right = map_limits.end.x
	limit_top = map_limits.position.y
	limit_bottom = map_limits.end.y
	Global.current_param = param
	
	if param.music != Radio.current_audio[&"music"] && param.music != &"same": Radio.change_stream(&"music",param.music)
	if param.ambience != Radio.current_audio[&"ambience"] && param.ambience != &"same": Radio.change_stream(&"ambience",param.ambience)
	
	if param.music_volume != -1: Radio.change_volume(&"music",param.music_volume)
	if param.ambience_volume != -1: Radio.change_volume(&"ambience",param.ambience_volume)
	
	for entity in get_tree().get_nodes_in_group("entity"):
		if entity.position.x > map_limits.position.x && entity.position.x < map_limits.end.x && entity.position.y > map_limits.position.y && entity.position.y < map_limits.end.y:
			entity.current_screen_status(true)
		else: entity.current_screen_status(false)
	
	var smoothing_timer = Global.new_timer(0.01)
	await smoothing_timer.timeout
	position_smoothing_enabled = true

func _process(_delta):
	if follow_target && target != null:
		position = target.position + cam_offset
		if target.name == &"Player":
			var move_direction = Input.get_vector("cam_left","cam_right","cam_up","cam_down")
			if Console.visible == true: move_direction = Vector2.ZERO
			cam_offset.x = move_direction.x * 100
			cam_offset.y = move_direction.y * 100
			if move_direction != Vector2.ZERO:
				if !player.looking: player.looking = true
			elif player.looking: player.looking = false
		else:
			player.looking = false
			cam_offset = Vector2.ZERO
	
	if Global.spin: rotation_degrees += Global.spin_param

func zoom_tween(zoom_value : Vector2, speed := 0.5, rebound := false , mandatory := true, return_to := 0.0):
	if zooming or (!mandatory && !Global.screen_shake): return
	zooming = true
	var tween = create_tween()
	var prev_value = zoom
	if return_to != 0.0: prev_value = Vector2(return_to,return_to)
	tween.tween_property(self,"zoom",zoom_value,speed)
	if rebound: tween.tween_property(self,"zoom",prev_value,speed)
	await tween.finished
	zooming = false

func rotate_tween(rotate_value : float, speed := 0.5, rebound := false, rand := false, mandatory := true):
	if rotating or (!mandatory && !Global.screen_shake): return
	rotating = true
	var tween = create_tween()
	var prev_value = rotation
	if rand && randi_range(0,1) == 1: rotate_value *= -1
	tween.tween_property(self,"rotation_degrees",rotate_value,speed)
	if rebound: tween.tween_property(self,"rotation_degrees",prev_value,speed)
	await tween.finished
	rotating = false

func epic_spin(param:float):
	if param == 0: Global.spin = false
	else: Global.spin = true
	
	Global.spin_param = param
