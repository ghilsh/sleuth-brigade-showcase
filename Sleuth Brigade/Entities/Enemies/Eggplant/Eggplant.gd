extends "res://Entities/Enemies/Enemy.gd"

func _ready():
	super()
	sprite_index = {&"roaming":0,&"alert":2,&"flee":3,&"hurt":3}
	hp = 5
	roam_parameters = [300,500]

func spotted_target():
	change_state(&"flee")

func change_state(new_state):
	super(new_state)
	for timer in get_tree().get_nodes_in_group("eggplant_timer"): timer.queue_free()
	
	match current_state:
		&"flee":
			face_target(player)
			animate_bob = true
			jump_height = 25
			var disappear_timer = Global.new_timer(1.0)
			disappear_timer.add_to_group("eggplant_timer")
			
			await disappear_timer.timeout
			
			if current_state != &"flee": return
			save_death()
			var fade_tween = create_tween()
			fade_tween.tween_property(self, "modulate", Color(0,0,0,0), 0.2)
			
			await fade_tween.finished
			
			queue_free()

func ended_bob():
	super()
	match current_state:
		&"flee": 
			if sprite.frame == 3: sprite.frame = 4
			else: sprite.frame = 3

func _process(delta):
	super(delta)
	match current_state:
		&"flee":
			var target_velocity = (global_position - player.global_position).normalized()
			velocity = target_velocity.normalized() * 450
