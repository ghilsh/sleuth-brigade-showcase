extends Node2D

@export var id : int = 1
@onready var sprite := $Sprite
@onready var animation_player = $AnimationPlayer
var current_character := &""
var character_offset := {&"green":Vector2(5,0),&"cashier":Vector2(7,0),&"child":Vector2(6,0)}

var prev_expression := &""
var init_time : float = 0.0
var init_pos := Vector2.ZERO
var base_pos : Vector2
@export var animate_bob : bool = false:
	set(value):
		if animate_bob != value:
			animate_bob = value
			if value == true: init_time = Global.time

func _ready():
	if init_pos == Vector2.ZERO: init_pos = global_position
	add_to_group("portrait")
	if position.x > 600: scale.x = -1
#	if position.x > 600: sprite.flip_h = true

func _process(_delta):
	if animate_bob:
		if sprite.position.y > base_pos.y: init_time = Global.time
		var bob_time = Global.time - init_time
		sprite.position.y = base_pos.y - Global.get_sine(bob_time,10,5)

func match_character(character : StringName, expression : StringName):
	if current_character == &"" or current_character == character or (expression.left(10) == &"knifepoint" && (prev_expression.left(10) == &"knifepoint" or prev_expression == &"")):
		var new_sprite = load("res://Assets/Images/Portraits/portrait_"+String(character)+"_"+String(expression)+".png")
		sprite.set_texture(new_sprite)
		current_character = character
		sprite.position.x = (sprite.texture.get_width() / 4) * 5
		sprite.position.y = -(sprite.texture.get_size().y / 2)*5
		base_pos = sprite.position
		sprite.flip_h = false
		prev_expression = expression
	else: animate_change(character,expression)

func animate_change(character : StringName, expression : StringName):
	var new_portrait = duplicate()
	var change_tween := create_tween()
	var mult := -300
	if position.x > 600: mult = 300
	new_portrait.init_pos = init_pos
	new_portrait.global_position = Vector2(init_pos.x+mult,init_pos.y)
	new_portrait.prev_expression = expression
	change_tween.tween_property(new_portrait,"global_position",init_pos,0.25)
	if get_parent().current_portrait == self: get_parent().current_portrait = new_portrait
	new_portrait.current_character = character
	new_portrait.call_deferred("match_character",character,expression)
	
	new_portrait.id = id
	get_parent().add_child(new_portrait)
	
	id = 9999
	change_tween.parallel().tween_property(self,"global_position",Vector2(init_pos.x+mult,init_pos.y),0.25)
	
	await change_tween.finished
	
	queue_free()

func match_focus():
	var zoom_amount = 5
	var modulate_colour = Color(1, 1, 1)
	var speed = 0.25
	if self != get_parent().current_portrait:
		zoom_amount = 4.8
		modulate_colour = Color(0.5, 0.5, 0.5)
	
	if scale.x != zoom_amount:
		var focus_tween = create_tween()
		focus_tween.tween_property(sprite, "scale", Vector2(zoom_amount,zoom_amount), speed)
		focus_tween.parallel().tween_property(sprite, "modulate", modulate_colour, speed)
