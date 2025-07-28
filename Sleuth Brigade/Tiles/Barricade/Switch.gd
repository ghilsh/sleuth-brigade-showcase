extends Area2D

@onready var sprite := $Switch
@onready var animation_player := $AnimationPlayer

@export var tag := 0

var in_range := false
var active := false

func _ready():
	body_entered.connect(set_range.bind(true))
	body_exited.connect(set_range.bind(false))
	add_to_group("switch")

func _input(event):
	if event.is_action_pressed("select") && in_range && !active:
		active = true
		animation_player.play("click")
		
		var all_switches := true
		for switch in get_tree().get_nodes_in_group("switch"):
			if switch.active == false && switch.tag == tag:
				all_switches = false
		if all_switches: get_tree().call_group("barricade","open",tag)

func set_range(body,value): 
	if body.is_in_group("player"): in_range = value
