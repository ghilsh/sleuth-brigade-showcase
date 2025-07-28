extends Node

@onready var red_scene := preload("res://Entities/NPCs/BikerRed/BikerRed.tscn")
@onready var follower_scene := preload("res://Entities/Followers/DougFollower/DougFollower.tscn")
@onready var player := $"../Player"
@onready var doug := $"../Doug"
@onready var red := $"../RedBoss"
@onready var green := $"../Green"

var doug_walk := false

func _ready():
	Global.plot = 4
	Radio.fadeout(5.0)
	player.active = false
	player.battle_mode = false
	var textbox = Global.create_textbox("BikerDefeat")
	await red.velocity_stopped
	
	var red_instance = red_scene.instantiate()
	red_instance.global_position = red.global_position
	get_parent().add_child(red_instance)
	red.queue_free()
	red = red_instance
	red.get_node("DialogArea/CollisionShape2D").disabled = true
	red.roaming = false
	player.active = false
	
	await textbox.queue_ended
	
	var jump_tween := create_tween()
	get_tree().call_group(&"cone",&"despawn_cones")
	player.get_node("AnimationPlayer").play("flip")
	red.get_node("AnimationPlayer").play("jump")
#	jump_tween.tween_property(player,"global_position",Vector2(7520,-896),0.5)
#	jump_tween.parallel().tween_property(red,"global_position",Vector2(7968,-896),0.5)
	jump_tween.tween_property(player,"global_position",Vector2(7600,-896),0.5)
	jump_tween.parallel().tween_property(red,"global_position",Vector2(7800,-896),0.5)
	Global.player_facing = Vector2(1,1)
	red.get_node("Sprite").flip_h = true
	var ifyoureadataminerreadingthisyoushouldtotalygocheckoutthealbumthenewsoundbygeordiegreepitactuallyfuckshardipinkypromise = Global.new_timer(0.85)
	
	await ifyoureadataminerreadingthisyoushouldtotalygocheckoutthealbumthenewsoundbygeordiegreepitactuallyfuckshardipinkypromise.timeout
	
	var jumped_textbox = Global.create_textbox("BikerDefeat","jumped")
	
	await jumped_textbox.queue_ended
	
	Radio.change_stream("music","bikers")
	var camera = get_tree().get_nodes_in_group("camera")[0]
	var shove_timer = Global.new_timer(0.5)
	camera.target = doug
	await shove_timer.timeout
	
	var shove_tween := create_tween()
	var prev_height = doug.jump_height
	doug.jump_height = 30
	camera.zoom_tween(Vector2(1.2,1.2),0.2,true,true,1.0)
	camera.rotate_tween(2,0.2,true)
	doug.bob_animation(true)
	green.bob_animation(true)
	shove_tween.tween_property(doug,"global_position",Vector2(doug.global_position.x,(doug.global_position.y+100)),0.25)
	shove_tween.parallel().tween_property(green,"global_position",Vector2(green.global_position.x,(green.global_position.y-20)),0.25)
	
	await shove_tween.finished
	var wait_timer = Global.new_timer(0.5)
	await wait_timer.timeout
	
	camera.target = red
	doug.jump_height = prev_height
	red.sprite.frame = 1
	red.sprite.flip_h = false
	red.get_node("AnimationPlayer").play("jump")
	var stomp_tween = create_tween()
	stomp_tween.tween_property(red,"global_position",Vector2((green.global_position.x-100),green.global_position.y),0.8)
	
	await red.get_node("AnimationPlayer").animation_finished
	
	doug.sprite.frame = 1
	doug.sprite.flip_h = true
	for chara in [red,green]: 
		chara.velocity.y = -0.1
		chara.get_node("AnimationPlayer").play("charge")
	camera.zoom_tween(Vector2(1.5,1.5),0.7)
	var goodbye_bikers_timer = Global.new_timer(0.9)
	var change_focus_timer = Global.new_timer(1.0)
	await goodbye_bikers_timer.timeout
	
	for chara in [red,green]: chara.velocity.y = -600
	camera.zoom_tween(Vector2(0.8,0.8),0.2,true,true,1.0)
	camera.rotate_tween(3,0.2,true)
	
	await change_focus_timer.timeout
	camera.target = doug
	Radio.fadeout(5.0)
	
	var doug_timer = Global.new_timer(1.0)
	await doug_timer.timeout
	
	var doug_textbox = Global.create_textbox("BikerDefeat","doug")
	await doug_textbox.queue_ended
	
	var walk_timer = Global.new_timer(1.0)
	doug.sprite.frame = 0
	await walk_timer.timeout
	
	var walk_tween = create_tween()
	walk_tween.tween_property(doug,"global_position",Vector2((player.global_position.x+100),player.global_position.y),0.6)
	doug_walk = true
	camera.zoom_tween(Vector2(1.0,1.0),0.6)
	await walk_tween.finished
	
	doug_walk = false
	var introductions_textbox = Global.create_textbox("BikerDefeat","introductions")
	await introductions_textbox.queue_ended
	
	var follower_instance = follower_scene.instantiate()
	follower_instance.global_position = doug.global_position
	get_parent().add_child(follower_instance)
	follower_instance.get_node("Sprite").flip_h = true
	doug.queue_free()
	
	camera.target = player
	player.active = true
	for chara in [red,green]: chara.queue_free()
	
	Radio.change_stream("music",get_tree().get_current_scene().music)
	Radio.change_stream("ambience",get_tree().get_current_scene().ambience)
	Radio.change_volume("music",get_tree().get_current_scene().music_volume)
	Radio.change_volume("ambience",get_tree().get_current_scene().ambience_volume)

func _process(_delta):
	if doug_walk: doug.bob_animation()
