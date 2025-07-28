extends Node

var plot : int = 999
var time : float
var entry_tag : int = 999
var player_facing : Vector2 = Vector2(1,0)
var screen_shake := true
var timer_enabled := false
var volume := 1.0
var current_param : ReferenceRect

# DEBUG
var debug := true
var speed_multiplyer := 1.0
var spin := false
var spin_param := 0.0
var debug_zoom := Vector2(1,1)
var keep_item := false
var show_fps := false

var inventory : Array = []
var inventory_capacity : int = 3
var current_slot : int = 0:
	set(value):
		if value >= 0: current_slot = value
		get_tree().call_group("item_slots","match_sprite")

var items_index : Dictionary = {
	&"beartrap":[preload("res://Items/Beartrap.tscn"),preload("res://Assets/Images/beartrap.png"),2],
	&"speaker":[preload("res://Items/Speaker.tscn"),preload("res://Assets/Images/speaker.png"),2],
	&"bomb":[preload("res://Items/Bomb.tscn"),preload("res://Assets/Images/bomb.png"),1],
	&"launcher":[preload("res://Items/Launcher.tscn"),preload("res://Assets/Images/launcher_ui.png"),1],
	&"barrel":[preload("res://Items/Barrel.tscn"),preload("res://Assets/Images/barrel_overworld.png"),1],
	&"potion":[preload("res://Items/Launcher.tscn"),preload("res://Assets/Images/potion.png"),1],
	&"teleporter":[preload("res://Items/Beartrap.tscn"),preload("res://Assets/Images/teleporter.png"),1],
	&"null":[preload("res://Items/Beartrap.tscn"),preload("res://Assets/Images/null.png"),1]
}
var dead_index := {}
var remember_index := {}

var save_path := "res://save0.json"

@onready var textbox_scene : PackedScene = preload("res://UI/Textbox/Textbox.tscn")

func create_save():
	save_item_pos()
	var data := {
		"Room": get_tree().current_scene.scene_file_path,
		"Inventory": inventory,
		"Plot": plot,
		"EntryTag": entry_tag,
		"DeadIndex": dead_index,
		"RememberIndex": remember_index
		}
	
	var json_string = JSON.stringify(data)
	var save_file = FileAccess.open(save_path,FileAccess.WRITE)
	save_file.store_line(json_string)
	save_file.close()

func load_save():
	var save_file = FileAccess.open(save_path,FileAccess.READ)
	var json_string = save_file.get_as_text()
	save_file.close()
	
	var data = JSON.parse_string(json_string)
	inventory = data.Inventory
	plot = data.Plot
	entry_tag = data.EntryTag
	dead_index = data.DeadIndex
	remember_index = data.RememberIndex
	change_scene(data.Room)
	player_facing = Vector2(1,1)

func reset_default():
	inventory = []
	Global.plot = 0
	Global.entry_tag = 0
	dead_index = {}
	remember_index = {}
	player_facing = Vector2(1,1)

func change_scene(destination):
	if destination == "save": load_save()
	else:
		save_item_pos()
		handle_entities(destination)

func check_save():
	return FileAccess.file_exists(save_path)

func _ready():
	check_save()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	time += delta

func _input(event):
	if event.is_action_pressed("fullscreen") && !Console.visible: toggle_fullscreen()
	if event.is_action_pressed("toggle_debug"): debug = !debug

func give_item(item : StringName):
	if !items_index.has(item): item = &"null"
	inventory.append(item)
	get_tree().call_group("item_slots","match_sprite")

func take_item(slot : int):
	if (inventory.size()-1) == slot: current_slot -= 1
	inventory.remove_at(slot)
	get_tree().call_group("item_slots","match_sprite")

func toggle_fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func save_item_pos():
	var current_scene = get_tree().current_scene.scene_file_path
		
	for item in get_tree().get_nodes_in_group(&"item"):
		if item.placed:
			if !(Global.remember_index.has(current_scene) && 
			Global.remember_index[current_scene].has([str(item.actual_name.capitalize()),
			[snapped(item.global_position.x,0.01),snapped(item.global_position.y,0.01)]])):
				item.save_place()

func fade_scene(new_loc):
	var trans_scene = preload("res://UI/TransitionScreen/TransitionScreen.tscn").instantiate()
	trans_scene.location = new_loc
	add_child(trans_scene)

func get_sine(given_time, freq, amp):
	return sin(given_time * freq) * amp

func new_timer(delay : float):
	var timer = Timer.new()
	timer.one_shot = true
	timer.autostart = true
	timer.add_to_group("new_timer")
	timer.wait_time = delay
	timer.timeout.connect(timer.queue_free)
	get_tree().get_root().add_child.call_deferred(timer)
	return timer

func create_textbox(text, tag = ""):
	var textbox = textbox_scene.instantiate()
	textbox.text_path = text
	get_tree().root.add_child(textbox)
	
	var delete_list = []
	var text_queue = textbox.text_queue
	var start_point = null
	var end_point = null
	
	for line in textbox.text_queue:
		if line.has("Tag") && line["Tag"] == tag:
			start_point = text_queue.find(line)
		elif line.has("Tag") && line["Tag"] != tag && (start_point != null or tag == "") && end_point == null:
			end_point = text_queue.find(line) - 1
	
	if start_point == null: start_point = 0
	if end_point == null: end_point = text_queue.find(text_queue.back())
	
	for line in textbox.text_queue:
		if text_queue.find(line) < start_point or text_queue.find(line) > end_point: 
			delete_list.append(line)
	
	for line in delete_list: textbox.text_queue.erase(line)
	
	if !textbox.text_queue[0].has("Setup"):
		var found := false
		for entry in text_queue:
			if found == false:
				if entry["Portrait"] != text_queue[0]["Portrait"]:
					for portrait in get_tree().get_nodes_in_group("portrait"):
						if portrait.id == entry["Portrait"]: portrait.match_character(entry["Character"],entry["Expression"])
						found = true
	
	textbox.display_setup(textbox.text_queue[0])
	
	return textbox

func get_player():
	var player_group = get_tree().get_nodes_in_group("player")
	if player_group != []: return player_group[0]
	else: return null

func handle_entities(scene_name):
	if remember_index.has(scene_name):
		var list = remember_index[scene_name]
		for entry in list:
			var entry_name = entry[0].capitalize()
			for character in [" ","1","2","3","4","5","6","7","8","9"]:
				entry_name.replace(character,"")
			var entry_pos = entry[1]
			var entry_vector = Vector2(entry_pos[0],entry_pos[1])
			var entry_path = load("res://Items/"+str(entry_name)+".tscn")
			var entry_scene = entry_path.instantiate()
			entry_scene.name = entry_name
			entry_scene.global_position = entry_vector
			entry_scene.init_pos = entry_vector
			entry_scene.placed = true
			entry_scene.add_to_group("global_add")
			call_deferred("add_child",entry_scene)
	
	if scene_name != "save": get_tree().call_deferred("change_scene_to_file",scene_name)

func get_frames(sprite : Sprite2D, character : StringName):
	var width : int
	match character:
		&"travis": width = 27
		&"doug": width = 29
	
	@warning_ignore("integer_division")
	return sprite.texture.get_width() / width
