extends CPUParticles2D

@onready var light := $PointLight2D
@onready var death_range := $DeathRange
@onready var hurt_range := $HurtRange
@onready var player_range := $PlayerRange

var raycast_point := Vector2.ZERO

func init_explosion():
	visible = true
	$Explode.play()
	emitting = true
	light.visible = true
	var light_tween = create_tween()
	light_tween.tween_property(light,"energy",0.0,0.5)
	death_range.area_entered.connect(blast_enemy.bind(3))
	hurt_range.area_entered.connect(blast_enemy.bind(1))
	player_range.body_entered.connect(blast_player)
	get_tree().call_group("camera","zoom_tween",Vector2(1.2,1.2),0.2,true,false)
	get_tree().call_group("camera","rotate_tween",1.25,0.2,true,false,false)
	var timer = Global.new_timer(0.05)
	await timer.timeout
	death_range.queue_free()
	hurt_range.queue_free()
	player_range.queue_free()

func blast_enemy(area,damage):
	if area.name != &"HurtBox": return
	var body = area.get_parent()
	
	if !body.is_in_group("enemy"): return
	
	var raycast := RayCast2D.new()
	if raycast_point != Vector2.ZERO: raycast.global_position = raycast_point
	raycast.target_position = Vector2(999,0)
	raycast.collide_with_areas = true
	raycast.collide_with_bodies = true
	add_child(raycast)
	raycast.look_at(body.global_position)
	
	var timer = Global.new_timer(0.01)
	await timer.timeout
	if raycast.is_colliding() && (raycast.get_collider() == area or raycast.get_collider().get_parent().is_in_group("enemy")):
		body.receive_damage(damage)
		body.velocity += (body.global_position - global_position).normalized() * 500
		body.bob_animation(true)
		body.stop_velocity()

func blast_player(body):
	if body.is_in_group("player"):
		var raycast := RayCast2D.new()
		if raycast_point != Vector2.ZERO: raycast.global_position = raycast_point
		raycast.target_position = Vector2(999,0)
		add_child(raycast)
		raycast.look_at(body.global_position)
		
		var timer = Global.new_timer(0.01)
		await timer.timeout
		if raycast.is_colliding() && raycast.get_collider() == body:
			body.game_over()
			body.knockback_direction = (body.global_position - global_position).normalized() * 15
#		body.init_hurt()

func _ready():
	light.visible = false
	await $Explode.finished
	queue_free()
