extends "res://Entities/Bosses/Boss.gd"

@onready var hurtbox := $Hurtbox
@onready var defeat_cutscene_scene := preload("res://Cutscenes/BikerDefeat.tscn")

var jumps := 0
var can_bump_x := true
var can_bump_y := true
var spinning_speed := 900
var bumps := 0
var crashes := 0
var vulnerable := false
var hurtbox_size : float
var superjumps := 0
var superjump_speed := 100

func _ready():
	super()
	face_target(player)
	hurtbox.connect("body_entered",hurtbox_entered)
	hurtbox_size = $Hurtbox/CollisionShape2D.shape.radius
	Radio.change_stream(&"music",&"bikersbattle")
	
	change_state(&"chase")
	hp = 3

func _process(delta):
	super(delta)
	match current_state:
		&"chase":
			var direction = (player.global_position-global_position).normalized()
			velocity = direction * 225
			face_target(player)
		&"boost":
			jumps = 0
			for i in get_slide_collision_count():
				var collision_detected = get_slide_collision(i)
				var collider := collision_detected.get_collider()
				if collider.name == &"TileMap" or collider.is_in_group(&"player") or collider.is_in_group(&"cone"):
					@warning_ignore("narrowing_conversion")
					var angle : int = rad_to_deg(collision_detected.get_angle())
					$Sounds/ImpactQuiet.play()
					if !can_bump_x && angle == 90: return
					if !can_bump_y && angle != 90: return
					@warning_ignore("narrowing_conversion")
					velocity = rand_vel() * spinning_speed
					if $Sprite/Spinner.current_animation != &"spinning": $Sprite/Spinner.play("spinning")
					bumps += 1
					if bumps > 10: spinning_speed -= 100
					if spinning_speed <= 300:
						crashes += 1
						if hp == 1 && superjumps == 0: change_state(&"superjump")
						else: change_state(&"chase")
					
					if angle == 90:
						velocity.x *= -1
						can_bump_x = false
						var x_timer = Global.new_timer(0.1)
						await x_timer.timeout
						can_bump_x = true
					else:
						velocity.y *= -1
						can_bump_y = false
						var y_timer = Global.new_timer(0.1)
						await y_timer.timeout
						can_bump_y = true
				return
		&"superjump":
			var direction = (player.global_position-global_position).normalized()
			velocity = direction * superjump_speed
			face_target(player)

func change_state(new_state : String):
	super(new_state)
	$Hurtbox/CollisionShape2D.shape.radius = hurtbox_size
	$Sprite/Spinner.stop()
	$Hitbox.set_deferred("disabled",false)
	$Hurtbox/CollisionShape2D.set_deferred("disabled",false)
	$Sounds/Spinning.stop()
	velocity = Vector2.ZERO
	vulnerable = false
	animate_bob = true
	match current_state:
		&"chase":
			var time : float = randi_range(2,12)
			time /= 10
			var jumping_timer = Global.new_timer(time)
			await jumping_timer.timeout
			if current_state != &"chase": return
			if (hp == 2 && crashes > 0) or (hp == 1 && crashes > 1): change_state(&"breathing")
			elif jumps > 4: 
				if hp == 3: change_state(&"breathing")
				else: change_state(&"charging")
			else: change_state(&"jumping")
		&"jumping":
			face_target(player)
			jumps += 1
			animate_bob = false
			$BattleAnims.play("jump_charge")
			var timer = Global.new_timer(0.4)
			
			await timer.timeout
			
			$BattleAnims.play("jump")
			var direction = (player.global_position-global_position).normalized()
			direction.y /= 2
			velocity = direction * 1500
			var tween = create_tween()
			var rotate_value := 15
			if direction.x > 0: rotate_value = -15
			tween.tween_property(sprite,"rotation_degrees",rotate_value,0.2)
			tween.tween_property(sprite,"rotation_degrees",0,0.2)
			stop_velocity()
			await velocity_stopped
			if current_state == &"jumping": change_state(&"chase")
		&"charging":
			jumps = false
			face_target(player)
			$BattleAnims.play(&"charging")
			var charge_timer = Global.new_timer(1.0)
			await charge_timer.timeout
			change_state(&"boost")
			$Sounds/Spinning.play()
		&"boost":
			$Sounds/MotorbikeRevved.play()
			bumps = 0
			spinning_speed = 900
			var direction = (player.global_position-global_position).normalized()
			velocity = direction * spinning_speed
		&"breathing":
			vulnerable = true
			$BattleAnims.play(&"breathing")
			face_target(player)
			var resume_timer = Global.new_timer(hp*2)
			await resume_timer.timeout
			if current_state != &"breathing": return
			reset_values()
			$BattleAnims.play(&"RESET")
			change_state(&"chase")
#			$Hurtbox/CollisionShape2D.shape.radius = 42
		&"hurt":
			crashes = 0
			$BattleAnims.stop()
			$Sounds/Beeping.stop()
			$Sounds/Impact.play()
			face_target(player)
			hp -= 1
			velocity = (global_position-player.global_position).normalized() * 750
			stop_velocity()
			get_tree().call_group("camera","rotate_tween",3.5,0.2,true,true,false)
			get_tree().call_group("camera","zoom_tween",Vector2(1.15,1.25),0.2,true,false)
			
			var timer = Global.new_timer(1.0)
			await timer.timeout
			change_state(&"chase")
		&"superjump":
			$Hurtbox/CollisionShape2D.shape.radius = 65
			superjumps += 1
			superjump_speed = 100
			velocity = Vector2.ZERO
			animate_bob = false
			$BattleAnims.play(&"superjump")
			$Hitbox.set_deferred("disabled",true)
			$Hurtbox/CollisionShape2D.set_deferred("disabled",true)
			var jump_timer = Global.new_timer(0.7)
			await jump_timer.timeout
			superjump_speed = 350
			
			var slowdown_timer = Global.new_timer(1.85)
			var land_timer = Global.new_timer(2.0)
			await slowdown_timer.timeout
			superjump_speed = 100
			
			await land_timer.timeout
			
			$BattleAnims.play(&"superjump_land")
			var impact_timer = Global.new_timer(0.3)
			await impact_timer.timeout
			
			get_tree().call_group("camera","rotate_tween",4.5,0.2,true,true,false)
			get_tree().call_group("camera","zoom_tween",Vector2(1.25,1.25),0.2,true,false)
			$Hitbox.disabled = false
			$Hurtbox/CollisionShape2D.disabled = false
			var chase_timer = Global.new_timer(0.2)
			await chase_timer.timeout
			
			change_state(&"chase")
		&"hit":
			$BattleAnims.play(&"RESET")
			velocity = (global_position-player.global_position).normalized() * 600
			stop_velocity()
			var resume_timer = Global.new_timer(1.0)
			await resume_timer.timeout
			change_state(&"chase")
		&"defeat":
			var defeat_cutscene = defeat_cutscene_scene.instantiate()
			get_parent().add_child(defeat_cutscene)
			velocity = (global_position-player.global_position).normalized() * 750

func hurtbox_entered(body):
	if body == player:
		if vulnerable:
			player.bat.initiate_hit()
			change_state(&"hurt")
		else: hit_player()

func hit_player():
	if current_state == &"hit": return
	
	if current_state != &"boost": change_state(&"hit")
	player.hp -= 1
	player.knockback_direction = (player.global_position-global_position).normalized() * 15

func hp_depleted(_hp):
	super(_hp)
	reset_values()

func reset_values():
	jumps = 0
	bumps = 0
	crashes = 0

func rand_vel():
	var vel_norm := velocity.normalized()
	var new_vel := Vector2.ZERO
	var the_range := [5,8]
	new_vel.x = randi_range(the_range[0],the_range[1])
	new_vel.y = randi_range(the_range[0],the_range[1])
	if vel_norm.x < 0: new_vel.x /= -10
	else: new_vel.x /= 10
	if vel_norm.y < 0: new_vel.y /= -10
	else: new_vel.y /= 10
	return new_vel
