extends "res://Entities/Entity.gd"

@onready var player_range := $PlayerRange
@onready var range_hitbox := $PlayerRange/CollisionShape2D
@onready var collision := $Hitbox

var in_radius = false:
	set(value):
		in_radius = value
		if value: 
#			collision.set_deferred("disabled",true)
			range_hitbox.shape.set_deferred("radius",110.0)
		else:
#			collision.set_deferred("disabled",false)
			range_hitbox.shape.set_deferred("radius",75.0)

func _ready():
	super()
	player_range.body_entered.connect(detect_player.bind(true))
	player_range.body_exited.connect(detect_player.bind(false))
	animate_bob = true
	expressions_index = {&"neutral":0,&"blink":2,&"scared":3}
	
	target = Global.get_player()
	make_path()

func _process(_delta):
	super(_delta)
	if !in_radius: follow()
	else: velocity = Vector2.ZERO
	face_target(target)
	if velocity.y < -100: sprite.frame = 1
	else: sprite.frame = 0

func follow():
	var next_path_pos = navigation_agent.get_next_path_position()
	var dir := global_position.direction_to(next_path_pos)
	velocity = dir * 300

func detect_player(body,value):
	if body.is_in_group("player"): in_radius = value

func current_screen_status(_value):
	pass
