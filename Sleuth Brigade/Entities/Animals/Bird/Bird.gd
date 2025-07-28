extends "res://Entities/Entity.gd"

@onready var shadow := $Shadow
@onready var fly_range := $Range
@onready var collision := $CollisionShape2D
@onready var audio := $TomarTakingWing
@onready var screen_notifier := $VisibleOnScreenNotifier2D

var fading := false
var group_flying := false
var on_screen : bool

func initiate_fly():
	if roaming:
		roaming = false
		save_death()
		collision.queue_free()
		animation_player.play("fly")
		var fly_tween = create_tween()
		fly_tween.tween_property(shadow, "color", Color(0,0,0,0), 0.1)
		fly_tween.parallel().tween_property(sprite, "position", Vector2(sprite.position.x+100,init_height-500), 0.75).set_ease(Tween.EASE_IN)
		get_tree().call_group("bird","group_flight")
		var fade_timer = Global.new_timer(0.5)
		fade_timer.timeout.connect(initiate_fade)
		audio.play()
		
		await fly_tween.finished
		
		queue_free()

func group_flight():
	if !group_flying && on_screen:
		group_flying = true
		var new_timer : float = randi_range(10,20)
		new_timer /= 100
		var group_timer = Global.new_timer(new_timer)
		await group_timer.timeout
		initiate_fly()

func initiate_fade():
	if !fading:
		fading = true
		var fade_tween = create_tween()
		fade_tween.tween_property(sprite, "modulate", Color(0,0,0,0), 0.2)

func _process(_delta):
	super(_delta)

func _ready():
	roaming = true
	super()
	add_to_group("bird")
	fly_range.body_entered.connect(range_entered)
	var rand_int = randi_range(0,1)
	if rand_int == 0: sprite.flip_h = true
	single_bob = true
	screen_notifier.screen_entered.connect(set_on_screen.bind(true))
	screen_notifier.screen_exited.connect(set_on_screen.bind(false))

func range_entered(body):
	if body.is_in_group("player"): initiate_fly()

func current_screen_status(value):
	if roaming: super(value)

func set_on_screen(value):
	on_screen = value
