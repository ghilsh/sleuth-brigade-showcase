extends Area2D

@export var plot_param := Vector2(0,999)

@export var player : CharacterBody2D
@export var camera : Camera2D

func _ready():
	body_entered.connect(trigger_cutscene)
	player = Global.get_player()

func trigger_cutscene(body):
	if body.is_in_group("player"):
		if plot_param[0] <= Global.plot && plot_param[1] >= Global.plot:
			body.active = false
			initiate_cutscene()

func initiate_cutscene():
	pass

func teleport_entity(entity:CharacterBody2D,new_pos:Vector2):
	entity.current_screen_status(true)
	entity.global_position = new_pos
