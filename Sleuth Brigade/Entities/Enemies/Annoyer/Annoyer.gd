extends "res://Entities/Enemies/Enemy.gd"

@onready var annoy_range := $AnnoyRange
@onready var annoy_circle := $AnnoyRange/CollisionShape2D
@onready var hearing_range := $HearingRange

var in_radius := false
var annoy_list := []
var searching_audio := false
var can_hear := false

func _ready():
	super()
	hp = 2
	roam_parameters = [50,100]
	jump_height = 30
	sprite_index = {&"roaming":0,&"searching":1,&"hurt":5,&"alert":6}
	animate_bob = true
	searching_speed = 450
	annoy_range.body_entered.connect(detect_player.bind(true))
	annoy_range.body_exited.connect(detect_player.bind(false))
	hearing_range.body_entered.connect(detect_enemy.bind(true))
	hearing_range.body_exited.connect(detect_enemy.bind(false))

func _process(_delta):
	super(_delta)
	match current_state:
		&"searching":
			jump_height = 15
			if in_radius: change_state(&"annoy")
		&"annoy":
			velocity = Vector2.ZERO
			if !in_radius: change_state(&"searching")
# 			for entity in annoy_range.get_overlapping_bodies(): # probably bad to run this on every frame but cba rn
#				if entity.is_in_group("enemy"): collision.disabled = true
#				else: collision.disabled = false
			for enemy in annoy_list:
				if enemy.current_state == &"roaming" && can_hear:
					enemy.hear_audio(self)
					annoy_list.erase(enemy)

func change_state(new_state):
	super(new_state)
	set_deferred(&"collision.disabled",false)
	$Sounds/Annoy.stop()
	match current_state:
		&"alert":
			face_target(player)
			bob_animation()
		&"searching":
			sprite.flip_h = !sprite.flip_h
			annoy_circle.shape.radius = 150.0
		&"annoy":
			annoy_circle.shape.radius = 225.0
			$Sounds/Annoy.play()
			var timer = Global.new_timer(0.5)
			await timer.timeout
			if current_state != &"annoy": return
			can_hear = true
			for enemy in annoy_list:
				if !annoy_list.has(enemy): enemy.hear_audio(self)
		&"hurt":
			$Sounds/Hurt.play()
			face_target(target)
			bob_animation()

func spotted_target():
	if current_state != &"searching": change_state(&"searching")

func bob_animation(forced=false):
	if roaming: sprite.frame = 2
	super(forced)

func ended_bob():
	super()
	match current_state:
		&"roaming": if finished_bob: sprite.frame = 0
		&"searching": sprite.flip_h = !sprite.flip_h

func detect_player(body,value):
	if body.is_in_group("player"): in_radius = value

func detect_enemy(body,value):
	if body.is_in_group("enemy") && body != self:
		if value: annoy_list.append(body)
		else: annoy_list.erase(body)

func hear_audio(source):
	change_state(&"searching")
	target = source
	searching_audio = true

func spotted_audio():
	if searching_audio: 
		change_state(&"roaming")
		searching_audio = false
		face_target(target)
