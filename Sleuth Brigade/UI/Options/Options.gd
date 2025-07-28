extends VBoxContainer

@onready var volume_button := $Volume
@onready var fullscreen := $Fullscreen
@onready var shake := $Shake
@onready var timer := $Timer
@onready var back := $Back
@onready var select_sound := $Select

func _ready():
	fullscreen.grab_focus()
	fullscreen.pressed.connect(Global.toggle_fullscreen)
	shake.pressed.connect(toggle_shake)
	timer.pressed.connect(toggle_timer)
	for button in get_children():
		if button is Button: button.focus_entered.connect(button_hovered)

func toggle_shake(): Global.screen_shake = !Global.screen_shake
func toggle_timer(): Global.timer_enabled = !Global.timer_enabled

func _input(event):
	if is_instance_valid(get_viewport().gui_get_focus_owner()) && get_viewport().gui_get_focus_owner().name.to_lower() == &"volume":
		var new_volume := Global.volume
		if event.is_action_pressed("move_left"): new_volume -= 0.05
		elif event.is_action_pressed("move_right"): new_volume += 0.05
		if new_volume >= 0.0 && new_volume <= 1.0:
			Global.volume = round(new_volume*100)/100
			AudioServer.set_bus_volume_db(0, linear_to_db(Global.volume))

func _process(_delta):
	volume_button.text = &"Master Volume: <"+str(Global.volume*100)+&"%>"
	match DisplayServer.window_get_mode():
		DisplayServer.WINDOW_MODE_FULLSCREEN: fullscreen.text = &"Fullscreen: ON"
		DisplayServer.WINDOW_MODE_WINDOWED: fullscreen.text = &"Fullscreen: OFF"
	match Global.screen_shake:
		true: shake.text = &"Screen Shake: ON"
		false: shake.text = &"Screen Shake: OFF"
	match Global.timer_enabled:
		true: timer.text = &"Timer: ON"
		false: timer.text = &"Timer: OFF"

func button_hovered():
	select_sound.play()

func centre():
	for button in get_children():
		if button is Button:
			button.alignment = 1
