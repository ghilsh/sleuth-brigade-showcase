extends "res://Items/Item.gd"

@onready var hearing_range := $HearingRange
@onready var raycast := $RayCast2D
@onready var beeping := $Beeping
@onready var destroy_range := $DestroyRange

var bump_active := true
var bumped := false
var prev_vel : Vector2

func _ready():
	super()
	if used:
		var activate_timer = Global.new_timer(1.5)
		
		await activate_timer.timeout
		
		$AnimationPlayer.play("playing")
		beeping.play()
		pickupable = false
		for body in hearing_range.get_overlapping_bodies():
			if body.is_in_group("enemy"): body.hear_audio(self)
		var end_timer = Global.new_timer(5.0)
		
		await end_timer.timeout
		
		$AnimationPlayer.stop()
		beeping.stop()
		pickupable = true
		sprite.frame = 0

func use_item():
	super()
	slide_power = 800
	$Slide.play()

func _process(_delta):
	super(_delta)
	for enemy in get_tree().get_nodes_in_group(&"enemy"):
		if enemy.current_state == &"searching" && !pickupable:
			raycast.look_at(enemy.global_position)
			if raycast.is_colliding() and raycast.get_collider().is_in_group(&"enemy"):
				enemy.spotted_audio()
	
	for enemy in destroy_range.get_overlapping_bodies():
		if enemy.is_in_group(&"enemy") && enemy.target == self:
			queue_free()
	
	if !bumped && velocity == Vector2.ZERO && slide_power != 0:
		facing *= -0.25
		bumped = true

func bump(_body):
	if !bump_active: return
	facing *= -1
	slide_power *= 0.5
	bump_active = false
	var active_timer = Global.new_timer(0.1)
	await active_timer.timeout
	bump_active = true
