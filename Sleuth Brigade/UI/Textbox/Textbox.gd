extends CanvasLayer

@onready var dialog := $Dialog
@onready var cursor : Sprite2D = $Cursor
@onready var choicer := $Choicer
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var voiceblips : AudioStreamPlayer = $Voiceblips
@onready var portrait_scene := preload("res://UI/Textbox/Portrait.tscn")

enum State {READY, READING, FINISHED}
var current_state = State.READY: 
	set(new_value):
		current_state = new_value
		enter_state(new_value)

var current_portrait : Node2D
var text_queue : Array = []
var text_path : StringName
var dialog_path : StringName
var scroll_tween: Tween
var choices := []
var choosing := false

const SCROLL_SPEED = 0.022

signal queue_ended

func _ready():
	add_to_group("textbox")
	dialog_path = "res://Scripts/"+String(text_path)+".json"
	text_queue = read_file()
	voiceblips.finished.connect(play_voiceblip)
	
	await animation_player.animation_finished
	
	current_state = State.READY

func enter_state(new_state):
	match new_state:
		State.READY:
			var next_text = text_queue[0]
			text_queue.erase(next_text)
			display_text(next_text)
			current_state = State.READING
			cursor.visible = false
		State.READING:
			play_voiceblip()
		State.FINISHED:
			if !choices.is_empty():
				choicer.init(choices)
				choices = []
				choosing = true
			current_portrait.animation_player.play("stop_talking")
			cursor.visible = true

func _input(event):
	if event.is_action_pressed("select"):
		if current_state == State.FINISHED:
			if !choosing:
				if text_queue == []: close_box()
				else: current_state = State.READY
	elif event.is_action_pressed("hit"):
		if current_state == State.READING:
			scroll_tween.kill()
			dialog.visible_ratio = 1
			current_state = State.FINISHED

func display_setup(new_text):
	for portrait in get_tree().get_nodes_in_group("portrait"):
		if portrait.id == new_text["Portrait"]:
			current_portrait = portrait
			current_portrait.match_character(new_text["Character"],new_text["Expression"])
		if new_text.has("Setup"):
			var setup = new_text["Setup"]
			if portrait.id == setup[0]: 
				var expression = "neutral"
				if new_text["Setup"].size() > 2: expression = setup[2]
				portrait.match_character(setup[1],expression)
	if new_text.has("Sprite") && new_text["Sprite"] == "flipped": current_portrait.sprite.flip_h = true

func display_text(new_text):
	var text = new_text["Text"]
	
	if new_text.has("Setup"): display_setup(new_text)
	if new_text.has("Music"): Radio.change_stream("music",new_text["Music"])
	if new_text.has("Fadeout"): Radio.fadeout(new_text["Fadeout"])
	if new_text.has("Effect"):
		match new_text["Effect"]:
			"wave": text = "[wave amp=20.0 freq=15.0 connected=1]" + text
			"shake": text =  "[shake rate=20.0 level=15 connected=1]" + text
	if new_text.has("Choices"): choices = new_text["Choices"]
	if new_text.has("Question"): choicer.question_tag = new_text["Question"]
	
	dialog.text = text
	dialog.visible_ratio = 0
	
	var new_portrait_id = new_text["Portrait"]
	for portrait in get_tree().get_nodes_in_group("portrait"):
		if portrait.id == new_portrait_id: current_portrait = portrait
	current_portrait.match_character(new_text["Character"],new_text["Expression"])
	current_portrait.animation_player.play("talk")
	if new_text.has("Sprite") && new_text["Sprite"] == "flipped": current_portrait.sprite.flip_h = true
	
	scroll_tween = get_tree().create_tween()
	scroll_tween.tween_property(dialog, "visible_ratio", 1, len(remove_bbcode(dialog.text)) * SCROLL_SPEED)
	get_tree().call_group("portrait","match_focus")
	
	await scroll_tween.finished
	
	current_state = State.FINISHED

func close_box():
	animation_player.play_backwards("open")
	dialog.text = " "
	for portrait in get_tree().get_nodes_in_group("portrait"):
		portrait.get_node("AnimationPlayer").play_backwards("fade")
	
	await animation_player.animation_finished
	
	call_deferred("emit_signal","queue_ended")
	queue_free()

func play_voiceblip():
	if current_state == State.READING:
		var stream: AudioStream
		var randint = randi_range(1,10)
		stream = load("res://Assets/Audio/Sounds/Voiceblips/travis/travis_"+str(randint)+".ogg")
		voiceblips.set_stream(stream)
		voiceblips.play()

func queue_text(next_text):
	text_queue.push_back(next_text)

func read_file():
	var file = FileAccess.open(dialog_path, FileAccess.READ)
	var content = file.get_as_text()
	var finish = JSON.parse_string(content)
	return finish

func remove_bbcode(string):
	var regex := RegEx.new()
	regex.compile("\\[.+?\\]")
	var result := regex.sub(string,"",true)
	return result
