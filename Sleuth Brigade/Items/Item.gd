extends "res://Entities/Entity.gd"

@onready var body_range := $Range
@onready var take_range : CollisionShape2D = $Range/CollisionShape2D
@onready var item_name := name.to_lower()

var in_range : bool = false
var pickupable : bool = true
var facing = Vector2.ZERO
var used := false
var placed := false
var slide_power := 0.0:
	set(value):
		slide_power = value
	#	if value <= 0.0: $CollisionShape2D.disabled = true
	#	else: $CollisionShape2D.disabled = false
		if value <= 0.0: velocity = Vector2.ZERO

func _input(event):
	if event.is_action_pressed("select") && in_range :
		if (Global.inventory_capacity+1) > Global.inventory.size() && pickupable:
			collect_item()

func collect_item():
	Global.give_item(actual_name.to_lower())
	save_place(false)
	if !placed: save_death()
	get_tree().call_group("overlay","picked_up")
	queue_free()

func use_item():
	placed = true

func _ready():
	super()
	name = item_name
	player = Global.get_player()
	add_to_group("item")
	if used: use_item()
	body_range.body_entered.connect(collision_detected.bind(true))
	body_range.body_exited.connect(collision_detected.bind(false))

func _process(delta):
	super(delta)
	if slide_power > 0.0:
		velocity = slide_power * facing
		slide_power -= 1000.0 * delta
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() == null: return
		if (collision.get_collider().name == &"TileMap" or collision.get_collider().is_in_group("enemy")):
			slide_power *= 0.25

func collision_detected(body,value):
	if body.is_in_group("player"):
		in_range = value

func in_water():
	super()
	queue_free()

func launcher_behaviour(launcher_facing):
	super(launcher_facing)
	set_deferred(&"slide_power",0.0)
