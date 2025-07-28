extends "res://Items/Item.gd"

@onready var hitbox : Area2D = $Hitbox

var activated := false
var health := 3

func _ready():
	super()
	hitbox.body_entered.connect(hitbox_entered)

func hitbox_entered(body):
	if body.is_in_group("enemy") && !activated && body.current_state != &"trapped":
		target = body
		$AnimationPlayer.play("activate")
		pickupable = false
		body.change_state(&"trapped")
		save_place(false)
		activated = true
		struggle_behaviour()
		await target.killed
		broken()

func _process(_delta):
	super(_delta)
	if activated:
		target.position = position
		target.velocity = Vector2(0,0)

func struggle_behaviour():
	var time = randi_range(17,23)
	time /= 10
	var struggle_timer = Global.new_timer(time)
	await struggle_timer.timeout
	if !is_instance_valid(target) or target.current_state != &"trapped": return
	else: struggle()

func struggle():
	health -= 1
	var struggle_tween = create_tween()
	var pos_x = randi_range(-1,1)
	var pos_y = randi_range(0,1)
	var pos = Vector2(pos_x,pos_y)*7
	if pos == Vector2.ZERO: pos = Vector2(0,7)
	$Struggle.play()
	struggle_tween.tween_property(target.sprite,"position",target.sprite.position+pos,0.1)
	struggle_tween.tween_property(target.sprite,"position",target.sprite.position,0.1)
	if health == 0:
		broken()
		target.change_states = true
		target.change_state(&"roaming")
		target.bob_animation(true)
	else: struggle_behaviour()

func broken():
	activated = false
	$AnimationPlayer.play("broken")
	await $Break.finished
	queue_free()
