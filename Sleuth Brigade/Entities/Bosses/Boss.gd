extends "res://Entities/Entity.gd"

var previous_state : StringName
var current_state : StringName
var hp := 3:
	set(value):
		hp = value
		if value == 0: change_state(&"defeat")
		hp_depleted(value)

func _ready():
	super()
	player = Global.get_player()
	get_tree().call_group("overlay","toggle_health")

func _process(delta):
	super(delta)

func change_state(new_state : String):
	previous_state = current_state
	current_state = new_state

func hp_depleted(_hp):
	pass
