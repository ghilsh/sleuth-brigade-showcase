extends "res://Items/Item.gd"

@onready var explosion_scene = preload("res://Items/Explosion.tscn")
@onready var shadow := $Shadow
@onready var anim_player := $AnimationPlayer
@onready var activate_range := $ActivateRange

var locked_on := false
var stuck_body
var blowed_up := false

func use_item():
	super()
	slide_power = 600
	var explode_timer = Global.new_timer(1.0)
	$Ticking.play()
	anim_player.play(&"tick")
	await explode_timer.timeout
	if !blowed_up: create_explosion()

func collision_detected(body,value):
	super(body,value)
#	if !locked_on && body.is_in_group("enemy") && value:
#		locked_on = true
#		stuck_body = body
#		stuck_body.killed.connect(stuck_body_killed)
#		shadow.visible = false
#		sprite.position = Vector2(0,-60)

func stuck_body_killed():
	locked_on = false

func _process(_delta):
	super(_delta)
#	if locked_on: position = stuck_body.global_position
#	for i in get_slide_collision_count():
#		var collision = get_slide_collision(i)
#		if collision.get_collider().is_in_group(&"enemy"):
#			create_explosion()

func _ready():
	if used: activate_range.body_entered.connect(body_entered)
	super()

func body_entered(body):
	if body.is_in_group("enemy"): create_explosion()

func create_explosion():
	if blowed_up: return
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_parent().call_deferred("add_child",explosion)
	explosion.call_deferred("init_explosion")
	queue_free()
