extends Area2D

@export var camera_param1 : ReferenceRect
@export var offset1 := Vector2.ZERO
@export var camera_param2 : ReferenceRect
@export var offset2 := Vector2.ZERO

@onready var player := $"../../Player"
@onready var camera := $"../../Camera2D"
@onready var hitbox := CollisionShape2D

func _ready():
	body_entered.connect(on_entered)
	
func on_entered(body):
	if body.is_in_group("player") or body.is_in_group("barrel") or body.is_in_group("enemy"):
		if body.is_in_group("enemy"): if body.current_state != &"success": return
		var camera_param = camera_param2
		var offset = offset2
		if Global.current_param == camera_param2:
			camera_param = camera_param1
			offset = offset1
		
		camera.get_param(camera_param)
		
		if offset.x != 0: player.position.x = position.x + offset.x
		if offset.y != 0: player.position.y = position.y + offset.y
