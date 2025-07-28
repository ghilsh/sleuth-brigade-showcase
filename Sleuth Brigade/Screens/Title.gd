extends CanvasLayer

@onready var bg := $Bg
@onready var buttons := $Buttons
@onready var new := $Buttons/New
@onready var continue_button := $Buttons/Continue
@onready var options_button := $Buttons/Options
@onready var kickstarter := $Buttons/Kickstarter
@onready var quit := $Buttons/Quit
@onready var travis_sprite := $Travis/Sprite
@onready var animation_player := $Travis/AnimationPlayer
@onready var options := $Options

var sprite_index := {&"new":0,&"continue":1,&"options":2,&"kickstarter":3,&"quit":4}

func _ready():
	Radio.change_stream(&"music",&"title")
	Radio.change_stream(&"ambience",&"none")
	Radio.change_volume(&"music",100)
	new.grab_focus()
	new.pressed.connect(new_game)
	continue_button.visible = Global.check_save()
	continue_button.pressed.connect(continue_game)
	options_button.pressed.connect(scroll_screen.bind(true))
	kickstarter.pressed.connect(open_kickstarter)
	quit.pressed.connect(quit_game)
	for button in buttons.get_children():
		button.mouse_filter = 2
		button.focus_entered.connect(button_hovered)
	options.back.pressed.connect(scroll_screen.bind(false))
	bg.modulate = Color(0.659,0.659,0.659)

func new_game():
	Global.reset_default()
	var scroll_tween = create_tween()
	scroll_tween.tween_property(self,"offset",Vector2(0,324),0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	new.focus_mode = false
	Global.fade_scene("res://Screens/Intro.tscn")

func continue_game():
	continue_button.focus_mode = false
	var scroll_tween = create_tween()
	scroll_tween.tween_property(self,"offset",Vector2(0,324),0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	Global.fade_scene("save")

func scroll_screen(options_menu):
	$Sounds/Swoosh.play()
	get_viewport().gui_get_focus_owner().release_focus()
	animation_player.play("flip")
	travis_sprite.flip_h = !options_menu
	var scroll_tween = create_tween()
	var final_pos = Vector2.ZERO
	if options_menu: final_pos = Vector2(650,0)
	var final_colour = Color(0.659,0.659,0.659)
	if options_menu: final_colour = Color(0.65, 0.229, 1)
	scroll_tween.tween_property(self,"offset",final_pos,0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	scroll_tween.parallel().tween_property(bg,"modulate",final_colour,0.75)
	await scroll_tween.finished
	var new_button
	if options_menu: new_button = options.get_children()[0]
	else: new_button = options_button
	new_button.grab_focus()

func open_kickstarter():
	OS.shell_open("https://duckduckgo.com/?q=will+replace+with+kickstarter+link+when+done+lol&ia=web")

func quit_game():
	get_tree().quit()

func button_hovered():
	var current_button = get_viewport().gui_get_focus_owner().name.to_lower()
	if travis_sprite.frame != sprite_index[current_button]: 
		animation_player.stop()
		animation_player.play(&"change_pose")
		travis_sprite.frame = sprite_index[current_button]
		travis_sprite.flip_h = false
	$Sounds/Select.play()
