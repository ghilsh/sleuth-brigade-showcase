extends "res://Entities/Entity.gd"

@onready var player_range := $Range
@onready var collision := $CollisionShape2D

func _ready():
	roaming = true
	super()
	add_to_group("mouse")
	player_range.body_entered.connect(panic_state)
	player_range.area_entered.connect(panic_state)
	jump_height = 30
	single_bob = false

func _process(_delta):
	super(_delta)
	if velocity.x < 0: sprite.flip_h = true
	elif velocity.x > 0: sprite.flip_h = false

func panic_state(body):
	if (body.is_in_group("entity") or body.is_in_group("item")) && !body.is_in_group("mouse"):
		save_death()
		stopping_velocity = false
		roaming = false
		$Sounds/Squeak.play()
		$AnimationPlayer.play("run")
		bob_animation()
		
		var target_velocity = (global_position - body.global_position).normalized()
		var max_parameters = 0.75
		if target_velocity.x < max_parameters or target_velocity.x > -max_parameters: target_velocity.x /= 3
		if target_velocity.y < max_parameters or target_velocity.y > -max_parameters: target_velocity.y /= 3
		velocity = target_velocity.normalized() * 650
		
		var fade_timer = Global.new_timer(0.5)
		await fade_timer.timeout
		var tween = create_tween()
		if tween == null: return
		tween.tween_property(self,"modulate",Color(1,1,1,0),0.3)
		await tween.finished
		queue_free()
