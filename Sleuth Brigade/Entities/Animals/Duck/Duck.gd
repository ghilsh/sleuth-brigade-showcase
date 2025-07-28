extends "res://Entities/Entity.gd"

@onready var timer := $Timer
@onready var anim_player := $AnimationPlayer

func _ready():
	roaming = true
	single_bob = false
	super()
	init_quack()

func init_quack():
	var quack_time := randi_range(70,210)
	quack_time /= 10
	timer.wait_time = quack_time
	timer.start()
	await timer.timeout
	anim_player.play(&"quack")
	await anim_player.animation_finished
	init_quack()
