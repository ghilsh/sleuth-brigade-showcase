extends "res://Cutscenes/Cutscene.gd"

@onready var doug_intro_scene := preload("res://Cutscenes/DougIntro.tscn")
@onready var battle_intro_scene := preload("res://UI/BattleIntro/BattleIntro.tscn")
@onready var red_battle_scene := preload("res://Entities/Bosses/Red/RedBoss.tscn")
@onready var red := $"../../Red"
@onready var green := $"../../Green"
@onready var doug := $"../../Doug"

func initiate_cutscene():
	var textbox = Global.create_textbox("BikerIntro")
	Radio.fadeout(5.0)
	for chara in [red,green]: chara.visible = true
	
	await textbox.queue_ended
	
	Radio.change_stream("music","bikers")
	AudioServer.set_bus_volume_db(1, linear_to_db(0.25))
	red.global_position = Vector2(6830,-1105)
	green.global_position = Vector2(6760,-1105)
	camera.target = red
	var biker_timer = Global.new_timer(0.3)
	await biker_timer.timeout
	create_tween().tween_property(player,"global_position",Vector2(7715,-925),0.5)
	Global.player_facing.y = -1
	for chara in [red,green]: 
		chara.hitbox.disabled = true
		chara.velocity = Vector2(275,0)
	
	var red_timer = Global.new_timer(1.0)
	var land_timer = Global.new_timer(1.4)
	var green_timer = Global.new_timer(1.41)
	
	await red_timer.timeout
	
	red.velocity = Vector2.ZERO
	red.get_node("AnimationPlayer").play("jump")
	create_tween().tween_property(red,"global_position",player.global_position+Vector2(-150,-175),0.5)
	camera.target = red
	red.z_index = 3
	
	await land_timer.timeout
	camera.zoom_tween(Vector2(1.5,1.5),0.5)
	
	await green_timer.timeout
	
	green.velocity = Vector2.ZERO
	green.get_node("AnimationPlayer").play("jump")
	create_tween().tween_property(green,"global_position",player.global_position+Vector2(200,-225),0.75)
	await red.get_node("AnimationPlayer").animation_finished
	camera.target = green
	green.z_index = 3
	
	await green.get_node("AnimationPlayer").animation_finished
	
	green.sprite.flip_h = true
	var pose_timer = Global.new_timer(0.25)
	await pose_timer.timeout
	var resume_textbox = Global.create_textbox("BikerIntro","resume")
	camera.target = player
	camera.zoom_tween(Vector2(1,1),0.25)
	for chara in [red,green]: chara.z_index = 0
	
	await resume_textbox.queue_ended
	
	var doug_intro = doug_intro_scene.instantiate()
	get_tree().current_scene.add_child(doug_intro)
	
	doug_intro.global_position = player.global_position
	doug_intro.global_position += Vector2(75,-125)
	doug.global_position = doug_intro.global_position
	doug.visible = false
	doug.expression = &"scared"
	camera.target = doug
	
	await doug_intro.get_node("AnimationPlayer").animation_finished
	
	doug_intro.queue_free()
	doug.visible = true
	var doug_textbox = Global.create_textbox("BikerIntro","doug")
	camera.zoom_tween(Vector2(1,1),0.25)
	
	await doug_textbox.queue_ended
	
	var turn_timer = Global.new_timer(0.5)
	await turn_timer.timeout
	doug.sprite.flip_h = true
	
	var talk_timer = Global.new_timer(0.5)
	await talk_timer.timeout
	
	doug.expression = &"neutral"
	var turned_textbox = Global.create_textbox("BikerIntro","turned")
	
	await turned_textbox.queue_ended
	
	var knifepoint_timer = Global.new_timer(4.0)
	camera.zoom_tween(Vector2(1.25,1.25),4.0)
	camera.target = green
	
	await knifepoint_timer.timeout
	
	Radio.change_stream("music","bikers")
	camera.zoom_tween(Vector2(2.5,2.5),0.2,true,true,1.0)
	camera.rotate_tween(-10,0.2,true)
	var init_pos = green.global_position
	var tween := create_tween()
	green.bob_animation(true)
	green.get_node("Sounds/Multiswish").play()
	tween.tween_property(green,"global_position",doug.global_position+Vector2(10,-10),0.1)
	doug.expression = &"scared"
	green.get_node("Sounds/Impact").play()
	tween.tween_property(green,"global_position",init_pos,0.2)
	tween.parallel().tween_property(doug,"global_position",init_pos-Vector2(10,-10),0.2)
	
	await tween.finished
	var beat_timer = Global.new_timer(0.1)
	await beat_timer.timeout
	
	camera.target = player
	var end_textbox = Global.create_textbox("BikerIntro","knifepoint")
	
	await end_textbox.queue_ended
	
	Radio.fadeout(0.75)
	var battle_tween := create_tween()
	Global.player_facing = Vector2(1,1)
	player.get_node("AnimationPlayer").play("flip")
	red.get_node("AnimationPlayer").play("jump")
	battle_tween.tween_property(player,"global_position",Vector2(7520,-896),0.5)
	battle_tween.parallel().tween_property(red,"global_position",Vector2(7968,-896),0.5)
	
	var spawner_timer = Global.new_timer(0.2)
	var intro_timer = Global.new_timer(0.5)
	var turn_timer2 = Global.new_timer(1.1)
	
	await spawner_timer.timeout
	get_tree().call_group(&"conespawners",&"spawn_cones")
	
	await intro_timer.timeout
	
	var battle_intro = battle_intro_scene.instantiate()
	add_child(battle_intro)
	
	await turn_timer2.timeout
	red.sprite.flip_h = true
	
	await battle_intro.begin_battle
	
	var red_battle = red_battle_scene.instantiate()
	red_battle.global_position = red.global_position
	player.active = true
	get_parent().get_parent().add_child(red_battle)
	red.queue_free()
	queue_free()

func _ready():
	super()
	
	for chara in [red,green,doug]:
		chara.roaming = false
		chara.velocity = Vector2.ZERO
		chara.sprite.frame = 0
		chara.sprite.flip_h = false
		set_deferred("chara.hitbox.disabled",true)
