extends Node2D

@onready var area := $Area
@onready var animation_player := $Hitter
@onready var sprite := $Area/BatSprite
@onready var flasher := $Flasher
@onready var directioner := $Directioner
@onready var shapecast := $ShapeCast2D

var button_held := false
var charge : float = 0.5
var charging : bool = false
var charged : bool = false
var active := false

@export var flash_value : float = 0.0

func charge_hit():
	if !active:
		owner.speed = 50
		owner.animate_bob = false
		charge = 0.5
		charging = true
		charged = false
		active = true
		flasher.play("flash")

func _process(delta):
	if charging: charge -= 1.0 * delta
	if charge <= 0 && !charged:
		charged = true
		animation_player.play("ready")
	
	owner.sprite.material.set_shader_parameter('flash_value',flash_value)

func _input(event):
	if event.is_action_pressed("hit") && active: button_held = true
	if event.is_action_released("hit"):
		if active:
			if charge <= 0.0: initiate_hit()
			else: return_to_normal()
			charging = false
			button_held = false
	if owner.active: change_direction()

func change_direction():
	var move_direction = Input.get_vector("move_left","move_right","move_up","move_down")
	if move_direction.y > 0: directioner.play("down")
	elif move_direction.y < 0: directioner.play("up")
	elif move_direction.x > 0: directioner.play("right")
	elif move_direction.x < 0: directioner.play("left")

func initiate_hit():
	var impact := false
	charging = false
	animation_player.play("hit")
	owner.active = false
	var enemy : CharacterBody2D
	
	for area_instance in area.get_overlapping_areas():
		if area_instance.get_parent().is_in_group("enemy") && area_instance.name == &"HurtBox": # gets deathbox
			enemy = area_instance.owner
			if enemy.current_state != &"hurt":
				shapecast.target_position = (enemy.position - owner.position)
				var timer = Global.new_timer(0.05)
				await timer.timeout
				if !(shapecast.get_collision_count() > 1 && shapecast.get_collider(1).name == &"TileMap"):
					enemy.receive_damage(1)
					impact = true
	
	if impact:
		$Sounds/Impact.play()
		owner.knockback_direction = (owner.position - enemy.position).normalized() * 10
		enemy.velocity = -owner.knockback_direction * 2
		get_tree().call_group("camera","rotate_tween",0.75,0.15,true,true,false)
		get_tree().call_group("camera","zoom_tween",Vector2(1.1,1.1),0.15,true,false)
	else: $Sounds/Miss.play_varied()

func return_to_normal(value = "hit"):
	if value == "hit":
		owner.speed = 300
		owner.animate_bob = true
		flasher.stop()
		owner.active = true
		active = false
		if button_held && !charging: charge_hit()

func _ready():
	animation_player.animation_finished.connect(return_to_normal)
