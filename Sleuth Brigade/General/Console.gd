extends CanvasLayer

@onready var label = $Text
@onready var input = $Input

var player : CharacterBody2D
var history := []
var history_value := -1:
	set(value):
		history_value = value
		if history_value == -1: input.text = ""
		else: input.text = history[(history.size()-1)-history_value]

func _ready():
	if !Global.debug: queue_free()
	input.text_submitted.connect(on_run_command)
	visible = false
	input.set_focus_mode(false)

func on_run_command(init_cmd: String):
	history_value = -1
	var cmd = init_cmd
	input.text = ""
	if cmd == "":
		toggle_window(false)
		return
	elif cmd.contains(" "):
		cmd = cmd.replace(' ','("')
		cmd += '")'
	elif !cmd.contains("("): cmd += "()"
	add_text(init_cmd,false)
	
	var expression = Expression.new()
	var parse_error = expression.parse(cmd)
	if parse_error != OK:
		add_text("Invalid command I think")
		return
	
	var cmd_length := cmd.find("(")
	var cmd_name : StringName = cmd.left(cmd_length)
	if self.has_method(cmd_name): expression.execute([], self)
	else:
		add_text("Invalid command I think")
		return
	if history.size() >= 5: history.remove_at(0)
	if history.has(init_cmd): history.erase(init_cmd)
	history.append(init_cmd)

func add_text(text:String, grayed = true):
	if grayed: text = "[color=gray] - "+text
	else: text = "[color=white]"+text
	text = "[p]"+text
	label.text += text

func save():
	Global.create_save()

func load():
	Global.change_scene("save")
	toggle_window(false)

func reload():
	get_tree().reload_current_scene()
	add_text("As you wish")
	toggle_window(false)

func cleardeath():
	Global.dead_index.clear()
	add_text("Death index cleared")

func clearload():
	get_tree().reload_current_scene()
	toggle_window(false)
	Global.dead_index.clear()
	add_text("Death index cleared + reloaded")

func give(new_item):
	if !Global.items_index.has(new_item):
		add_text("But it was never found...")
		return
	Global.give_item(new_item)
	if new_item == &"bomb": add_text("YES!!! THIS ITEM IS THE BOMB!!!!!")
	else: add_text("Enjoy your "+new_item+" bud")

func debug():
	var value = !Global.debug
	Global.debug = value
	add_text("Debug toggled "+str(value))

func bucket():
	player = Global.get_player()
	var value = !player.bucket
	player.bucket = value
	add_text("Debug toggled "+str(value))

func room(value):
	value = value.capitalize()
	value = value.replace(' ','')
	get_tree().change_scene_to_file("res://Screens/Rooms/Room"+value+".tscn")
	add_text("Welcome to Room"+value+"...")
	toggle_window(false)

func plot(value = -1):
	value = int(value)
	if value == -1: add_text("Plot value currently "+str(Global.plot))
	else:
		Global.plot = value
		add_text("Plot value set to "+str(value))

func tp(value):
	value = int(value)
	Global.entry_tag = value
	get_tree().call_group("entry","init")
	get_tree().call_group("camera","set_param")
	add_text("WOAH!!! Teleported to entry point "+str(value))

func dialog(value):
	Global.create_textbox(value,"yabadabado")
	toggle_window(false)
	block_player(false)

func kill():
	if get_tree().get_nodes_in_group("enemy") == []: add_text("* But nobody came.")
	else:
		get_tree().call_group("enemy","change_state","death")
		add_text("Purification in process...")

func keepitem():
	Global.keep_item = !Global.keep_item
	add_text("Keep item toggled: "+str(Global.keep_item))

func cam(value=100):
	add_text("WOW!!!! ZOOMED TO "+str(value)+"%")
	value = int(value) * 0.01
	value = Vector2(value,value)
	get_tree().call_group("camera","zoom_tween",value,0.25)
	Global.debug_zoom = value

func info():
	get_tree().call_group("debug","toggle_label")
	add_text("Toggled debug info")

func spawn(value):
	value = value.capitalize()
	var enemy_scene := load("res://Entities/Enemies/"+value+"/"+value+".tscn")
	var enemy = enemy_scene.instantiate()
	
	Global.get_player().get_parent().add_child(enemy)
	enemy.global_position = player.global_position + Global.player_facing * 750
	enemy.set_values()
	
	add_text("Spawned in "+value)

func speed(value=1):
	Global.speed_multiplyer = int(value)
	add_text("Speed multiplyer is "+str(Global.speed_multiplyer))

func spin(value = 1):
	get_tree().call_group("camera","epic_spin",int(value))
	add_text("Wheeeeeeeeeeeeeeeeee")

func mute():
	AudioServer.set_bus_mute(0, !AudioServer.is_bus_mute(0))
	add_text("Toggled mute status: "+str(AudioServer.is_bus_mute(0)))

func awesome():
	OS.shell_open("https://www.youtube.com/watch?v=jT7RSSb-VVc")

func timer():
	Global.timer_enabled = !Global.timer_enabled
	add_text("Epic speedrunner mode activated")

func health():
	get_tree().call_group("overlay","toggle_health")
	toggle_window(false)

func fps(frames = -1):
	frames = int(frames)
	if frames == -1: Global.show_fps = !Global.show_fps
	else: Engine.max_fps = frames

func _input(event):
	if event.is_action_pressed("debug_console_init"):
		var value = !input.focus_mode
		toggle_window(value)
	elif event.is_action_pressed("debug_console_history_up") && history_value >= -1 && history_value < (history.size() - 1):
		history_value += 1
	elif event.is_action_pressed("debug_console_history_down") && history_value > -1:
		history_value -= 1

func toggle_window(value):
	input.set_focus_mode(value)
	visible = value
	if value: input.grab_focus()
	block_player(!value)
	history_value = -1

func _on_input_text_changed(new_text):
	if new_text.contains("/"): input.text = ""
	elif new_text.contains("zoom"):
		input.text = "cam"
		input.caret_column = input.text.length()

func block_player(value):
	var player_group = get_tree().get_nodes_in_group("player")
	if player_group != []: player = player_group[0]
	else: return
	player.active = value

func _on_text_finished():
	label.get_v_scroll_bar().value = label.get_v_scroll_bar().max_value
#	label.get_v_scroll_bar().value += 9999 
