extends CanvasLayer

@onready var black := $Black
@onready var health := $Health
@onready var hearts := $Health/Hearts
@onready var timer := $Timer
@onready var item_slots := $ItemSlots

var display_health := false

var animating_fade := false:
	set(value):
		animating_fade = value
		if value: animate_black()
		else: stop_black()

func _input(event):
	if event.is_action_pressed("change_slot_left"):
		change_slot(-1)
	elif event.is_action_pressed("change_slot_right"):
		change_slot(1)

func change_slot(value):
	if owner.active:
		var max_value : int = Global.inventory.size() - 1
		var new_value = Global.current_slot + value
		if new_value > max_value: Global.current_slot = 0
		elif new_value < 0: Global.current_slot = max_value
		else: Global.current_slot = new_value

func _ready():
	visible = true
	add_to_group("overlay")

func use_item():
	var inventory = Global.inventory
	if inventory.size() > 0:
		var selected_item = inventory[Global.current_slot]
		if selected_item != &"empty":
			var item_scene = Global.items_index.get(selected_item)[0].instantiate()
			if !Global.keep_item: Global.take_item(Global.current_slot)
			item_scene.used = true
			
			var player = Global.get_player()
			if player.sprite.frame == 1: item_scene.facing = Vector2(0,-1)
			elif Global.player_facing.y > 0: item_scene.facing = Vector2(0,1)
			elif player.sprite.flip_h: item_scene.facing = Vector2(-1,0)
			else: item_scene.facing = Vector2(1,0)
			item_scene.global_position = player.global_position + (item_scene.facing * 50)
			
			if owner.shapecast.is_colliding() && (owner.shapecast.get_collider(0).name == &"TileMap" or owner.shapecast.get_collider(0).is_in_group(&"item")):
				item_scene.global_position = owner.shapecast.get_collision_point(0)
			
			player.get_parent().add_child(item_scene)
			$Place.play()

func picked_up():
	$Pickup.play()

func animate_black():
	$Heartbeat.play()
	var fade_tween := create_tween()
	fade_tween.tween_property(black,"color",Color(0,0,0,0.3),0.5).set_ease(Tween.EASE_IN_OUT)
	fade_tween.tween_property(black,"color",Color(0,0,0,0),0.5).set_ease(Tween.EASE_IN_OUT)
	await fade_tween.finished
	if animating_fade: animate_black()

func stop_black():
	var fade_tween := create_tween()
	fade_tween.tween_property(black,"color",Color(0,0,0,0),0.5)
	$Heartbeat.stop()

func set_timer():
	if !timer.visible: timer.visible = true
	var time = Global.time
	
	var mils = fmod(time,1)*1000
	var secs = fmod(time,60)
	var mins = fmod(time, 60*60)/60
	var hours = (fmod(time, 60*60)/60)/60
	
	var time_passed = "%02d:%02d:%02d.%02d" % [hours, mins, secs, mils]
	$Timer/Text.text = time_passed

func toggle_health():
	display_health = !display_health
	var tween = create_tween()
	if display_health:
		owner.battle_mode = true
		health.scale = Vector2(0.025,0.025)
		health.position = Vector2(-30,0)
		tween.tween_property(health,"position",Vector2.ZERO,0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(health,"scale",Vector2(1,1),0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(timer,"position",Vector2(260,0),0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(item_slots,"position",Vector2(0,-160),0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	else: # 192
		owner.battle_mode = false
		tween.tween_property(health,"position",Vector2(-30,0),0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(health,"scale",Vector2(0.025,0.025),0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(timer,"position",Vector2(0,0),0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(item_slots,"position",Vector2(0,0),0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

func _process(_delta):
	if Global.timer_enabled: set_timer()
	else: timer.visible = false
	if Global.show_fps: 
		$FPS.visible = true
		$FPS.text = "FPS: "+str(Engine.get_frames_per_second())
	else: $FPS.visible = false
