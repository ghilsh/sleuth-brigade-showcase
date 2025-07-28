extends "res://Items/Item.gd"

func use_item():
	super()
	velocity = (facing*700)
	global_position = player.global_position
	if player.get_node_or_null("Hitbox") != null: player.collision.set_deferred("disabled",true)
	player.visible = false
	player.active = false
	$Range/CollisionShape2D.set_deferred("disabled",true)
	$Sounds/Start.play()
	$Sounds/Roll.play()
	if facing.x != 0: sprite.frame = 1
	else: sprite.frame = 5

func _process(_delta):
	super(_delta)
	if placed: 
		player.global_position = global_position
		bob_animation()
		
		for i in get_slide_collision_count():
			var collision_detectedd = get_slide_collision(i)
			if collision_detectedd.get_collider().is_in_group("enemy"): collision_detectedd.get_collider().receive_damage(1)
			crashed()

func bob_animation(forced = false):
	super(forced)

func ended_bob():
	super()
	jump_height = randi_range(10,15)
	if sprite.frame == 4 && facing.x > 0: sprite.frame = 1
	elif sprite.frame == 1 && facing.x <= 0: sprite.frame = 4
	elif sprite.frame == 6: sprite.frame = 5
	elif facing.x < 0: sprite.frame -= 1
	else: sprite.frame += 1

func crashed():
	player.visible = true
	if player.get_node_or_null("Hitbox") != null: player.collision.disabled = false
	placed = false
	player.launcher_behaviour(-facing/2)
	visible = false
	$CollisionShape2D.disabled = true
	$Sounds/Smash.play()
	$Sounds/Impact.play()
	$Sounds/Roll.stop()
	
	var rotate_tween := create_tween()
	rotate_tween.tween_property(player.sprite, "rotation_degrees", (facing.x*20), 0.1)
	rotate_tween.tween_property(player.sprite, "rotation_degrees", -(facing.x*10), 0.1)
	rotate_tween.tween_property(player.sprite, "rotation_degrees", 0, 0.1)
	
	await player.finished_launch
	player.active = true
	await $Sounds/Smash.finished
	queue_free()

func _ready():
	super()
	add_to_group("barrel")

func launcher_behaviour(launcher_facing):
	facing = launcher_facing
	use_item()

func current_screen_status(_value):
	pass
