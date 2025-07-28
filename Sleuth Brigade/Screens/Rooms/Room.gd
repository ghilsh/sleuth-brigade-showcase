extends Node2D

@onready var tile_map := $TileMap

@export var outside : bool = true
@export var music : StringName = &"none"
@export var ambience : StringName = &"none"
@export var music_volume : float = 100.0
@export var ambience_volume : float = 100.0

func _ready():
	if Global.plot == 4 && name != &"RoomCave": spawn_follower(&"doug")
	
	add_to_group(&"room")
	y_sort_enabled = true
	
	if !outside: RenderingServer.set_default_clear_color(Color(0,0,0))
	else: RenderingServer.set_default_clear_color(Color(0.302,0.302,0.302))
	
	if get_node_or_null("CameraParam") == null:
		if music != Radio.current_audio[&"music"]: Radio.change_stream(&"music",music)
		if ambience != Radio.current_audio[&"ambience"]: Radio.change_stream(&"ambience",ambience)
		Radio.change_volume(&"music",music_volume)
		Radio.change_volume(&"ambience",ambience_volume)
	
	tile_map.z_index = -1
	tile_map.set_collision_visibility_mode(2)
	
	for node in get_tree().get_nodes_in_group("global_add"):
		node.call_deferred("reparent",self)

	var current_scene = get_tree().current_scene.scene_file_path
	if Global.dead_index.has(current_scene):
		var list = Global.dead_index[current_scene]
		for entity in get_tree().get_nodes_in_group("entity"):
			if list.has([entity.global_position.x,entity.global_position.y]):
				entity.queue_free()

func change_default_music(new_default):
	music = new_default
	for param in get_tree().get_nodes_in_group("param"):
		if param.same_music: param.music = new_default

func spawn_follower(follower_name):
	var follower_scene
	if follower_name == &"doug": follower_scene = preload("res://Entities/Followers/DougFollower/DougFollower.tscn")
	var follower_instance = follower_scene.instantiate()
	follower_instance.global_position = Global.get_player().global_position - (Global.player_facing*10)
	add_child(follower_instance)
