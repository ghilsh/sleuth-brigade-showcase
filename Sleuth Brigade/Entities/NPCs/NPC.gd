extends "res://Entities/Entity.gd"

@onready var dialog_area : Area2D = $DialogArea
@onready var hitbox := $Hitbox
@export var dialog := &"Placeholder"

var active : bool = false
var talkable : bool = true
var expression_preblink : StringName
var spoken := 0
var dialog_tag := ""

func _ready():
	roaming = true
	dialog_area.body_entered.connect(set_active.bind(true))
	dialog_area.body_exited.connect(set_active.bind(false))
	back_sprite = true
	roam_parameters = [300,500]
	animate_bob = true
	init_blink()
	super() # put at end cause of the roaming randomizing part in entity ready
	if sprite.hframes == 3: expressions_index = {&"neutral":0,&"blink":2}

func _process(_delta):
	super(_delta)
	handle_animation()

func set_active(body,new_active):
	if body.is_in_group("player"):
		active = new_active

func _input(event):
	for item in get_tree().get_nodes_in_group("item"):
		if item.in_range: return
	if event.is_action_pressed("select") && active && talkable && get_tree().get_nodes_in_group("textbox") == []:
		get_dialog()
		var textbox = Global.create_textbox(dialog,dialog_tag)
		player.active = false
		talkable = false
		face_target(player)
		player.face_target(self)
		var was_roaming = roaming
		roaming = false
		if expression == &"blink": expression = expression_preblink
		
		await textbox.queue_ended
		
		player.active = true
		talkable = true
		roaming = was_roaming
		spoken += 1

func get_dialog():
	if spoken > 0: dialog_tag = &"spoken"

func init_blink():
	var rand_time : float = randi_range(20,100)
	var blink_timer = Global.new_timer(rand_time/10)
	await blink_timer.timeout
	expression_preblink = expression
	if roaming && expressions_index.has(&"blink"): expression = &"blink"
	var normal_timer = Global.new_timer(0.25)
	await normal_timer.timeout
	if roaming: expression = expression_preblink
	init_blink()
