extends "res://Entities/Entity.gd"

@onready var pause_scene : PackedScene = preload("res://UI/Pause/Pause.tscn")
@onready var overlay : CanvasLayer = $Overlay
@onready var bat : Node2D = $Bat
@onready var collision := $Hitbox
@onready var sprite_pivot := $SpritePivot
@onready var bucket_back := $SpritePivot/BucketBack
@onready var bucket_front := $SpritePivot/BucketFront
@onready var shapecast := $ShapeCast2D

var speed : float = 300.0
var max_hp := 4
var hp := max_hp:
	set(value):
		if !vulnerable: return
		vulnerable = false
		hp = value
		if hp <= 0: game_over()
		else: hurt()
		overlay.get_node("Health/Hearts").visible = (hp > 0)
		$Sounds/Impact.play()
var vulnerable := true
var active : bool = true:
	set(value):
		active = value
		if value == false: velocity = Vector2(0,0)
var looking := false:
	set(value):
		looking = value
		if value: Global.speed_multiplyer = 0.1
		else:
			if active: Global.player_facing.y = 1
			Global.speed_multiplyer = 1.0
		animate_bob = !value
var bucket := false:
	set(value):
		bucket = value
		bucket_back.visible = value
		bucket_front.visible = value
var battle_mode := false

func _ready():
	super()
	add_to_group("player")
	handle_animation()
	animate_bob = true
	
	expressions_index = {&"neutral":0,&"hurt":2,&"damaged":4}
	back_index = {&"neutral":1,&"hurt":3,&"damaged":1}

func _physics_process(_delta):
	handle_movement()
	if sprite.frame == 1: shapecast.target_position = Vector2(0,-1) * 50
	elif Global.player_facing.y > 0: shapecast.target_position = Vector2(0,1) * 50
	elif sprite.flip_h: shapecast.target_position = Vector2(-1,0) * 50
	else: shapecast.target_position = Vector2(1,0) * 50

func _input(event):
	if active:
		if event.is_action_pressed("pause") && !event.is_echo():
			var pause_instance = pause_scene.instantiate()
			get_tree().root.add_child(pause_instance)
		if !battle_mode:
			if event.is_action_pressed("hit"):
				bat.charge_hit()
			if event.is_action_pressed("use"):
				overlay.use_item()

func handle_movement():
	var move_direction = Input.get_vector("move_left","move_right","move_up","move_down")
	var hurt_mult = 1
	if expression == &"hurt": hurt_mult = 0.1
	if active: velocity = ((move_direction * (speed*Global.speed_multiplyer)) + (knockback_direction*50)) * hurt_mult
	else: velocity = (knockback_direction*50)
	if looking:
		Global.player_facing = camera.cam_offset
	else:
		if velocity.x != 0: Global.player_facing.x = move_direction.x
		if velocity.y != 0: Global.player_facing.y = move_direction.y
	
#	if velocity != Vector2.ZERO && animate_bob && expression != &"hurt": bob_animation()
	handle_animation()

func handle_animation():
	if hp == 0: return
	if (velocity.x != 0 && velocity.y == 0) && !looking: Global.player_facing.y = 0
	if Global.player_facing.y >= 0: sprite.frame = expressions_index[expression]
	else: sprite.frame = back_index[expression]
	
	if Global.player_facing.x < 0: sprite.flip_h = true
	elif Global.player_facing.x > 0: sprite.flip_h = false
	if expression == &"hurt": jump_height = 5
	else: jump_height = 10

func game_over():
	hp = 0
	Radio.fadeout(1.0)
	get_tree().call_group("camera","zoom_tween",Vector2(1.5,1.5),1.25,false,true)
	expression = &"hurt"
	active = false
	$AnimationPlayer.play(&"game_over")
	await $AnimationPlayer.animation_finished
	Global.fade_scene("save")

func hurt():
	overlay.get_node("Health/Hearts").size.x = 30 * hp
	$AnimationPlayer.play(&"change_expression")
	expression = &"damaged"
	active = false
	var timer = Global.new_timer(0.5)
	await timer.timeout
	$AnimationPlayer.play(&"change_expression")
	expression = &"neutral"
	vulnerable = true
	active = true

func launcher_behaviour(facing):
	super(facing)
	var prev_active = active
	active = false
	knockback_direction = facing * 30
	await finished_launch
	active = prev_active

func current_screen_status(_value):
	pass

func init_hurt():
	animation_player.play(&"change_expression")
	overlay.animating_fade = true
	expression = &"hurt"
	var hurt_timer = Global.new_timer(3.0)
	await hurt_timer.timeout
	overlay.animating_fade = false
	expression = &"neutral"
	animation_player.play(&"change_expression")

func bob_animation(forced = false):
	super(forced)
	var orgin = bucket_front.position.y
	var tween = create_tween()
	tween.tween_property(bucket_front, "position", Vector2(bucket_front.position.x,orgin-5), 0.1).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(bucket_back, "position", Vector2(bucket_back.position.x,orgin-8), 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(bucket_front, "position", Vector2(bucket_front.position.x,orgin), 0.1).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(bucket_back, "position", Vector2(bucket_back.position.x,orgin), 0.1).set_ease(Tween.EASE_IN)
