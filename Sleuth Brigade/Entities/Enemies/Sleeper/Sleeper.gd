extends "res://Entities/Enemies/Enemy.gd"

@onready var explosion_scene = preload("res://Items/Explosion.tscn")

func _ready():
	super()
	sprite_index = {&"roaming":0,&"awoke":1,&"screaming":2,&"hurt":2}
	hp = 20

func _process(delta):
	super(delta)
	velocity = Vector2.ZERO

func change_state(new_state):
	if new_state == &"alert" or (new_state == &"hurt" && current_state != &"roaming"): return
	previous_state = current_state
	current_state = new_state
	if sprite_index.has(current_state): sprite.frame = sprite_index[new_state]
	else: sprite.frame = 0
	if animation_player.has_animation(new_state): animation_player.play(new_state)
	else: animation_player.play("change_state")
	
	match new_state:
		&"roaming":
			$Sounds/Snore.play()
		&"awoke":
			$Sounds/Whip.play()
			var awoke_timer = Global.new_timer(0.5)
			await awoke_timer.timeout
			change_state(&"screaming")
		&"screaming":
			$Sounds/Scream.play()
			create_tween().tween_property(sprite,"modulate",Color(1, 0.5, 0.5),1.2)
			var explode_timer = Global.new_timer(0.75)
			await explode_timer.timeout
			explode()
		&"hurt": change_state(&"screaming")
		&"death": super(&"death")

func hear_audio(_source):
	var awake_timer = Global.new_timer(0.4)
	await awake_timer.timeout
	change_state(&"awoke")

func explode():
	change_state(&"death")
	var explosion = explosion_scene.instantiate()
	explosion.scale *= 5
	explosion.amount = 200
	explosion.global_position = global_position# - Vector2(0,65)
	get_parent().add_child(explosion)
	explosion.init_explosion()
