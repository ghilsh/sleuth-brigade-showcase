extends CanvasLayer

@onready var buttons = $Buttons
@onready var resume_button = $Buttons/Resume
@onready var options_button = $Buttons/Options
@onready var menu_button = $Buttons/Menu
@onready var options = $Options

func _ready():
	resume_button.grab_focus()
	add_to_group("pause")
	get_tree().paused = true
	options.centre()
	
	resume_button.pressed.connect(unpause)
	options_button.pressed.connect(options_toggle.bind(true))
	options.back.pressed.connect(options_toggle.bind(false))
	menu_button.pressed.connect(back_to_menu)

func unpause():
	get_tree().set_deferred("paused", false) 
	queue_free()

func options_toggle(value):
	get_viewport().gui_get_focus_owner().release_focus()
	var tween = create_tween()
	if value:
		tween.tween_property(options,"modulate",Color(1,1,1,1),0.2)
		tween.parallel().tween_property(buttons,"modulate",Color(1,1,1,0),0.2)
		await tween.finished
		options.get_children()[0].grab_focus()
	else:
		tween.tween_property(options,"modulate",Color(1,1,1,0),0.2)
		tween.parallel().tween_property(buttons,"modulate",Color(1,1,1,1),0.2)
		await tween.finished
		options_button.grab_focus()

func back_to_menu():
	menu_button.focus_mode = false
	Global.fade_scene("res://Screens/Title.tscn")
	Radio.change_stream(&"music",&"none")
	Radio.change_stream(&"ambience",&"none")

func _input(event):
	if event.is_action_pressed("pause") && !event.is_echo():
		unpause()
