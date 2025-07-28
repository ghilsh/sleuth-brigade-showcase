extends Control

@onready var textbox := get_parent()

var choice := 0
var question_tag : String

signal shown

func _ready():
	for button in get_children():
		button.visible = false
		button.modulate = Color(1,1,1,0)
		button.pressed.connect(on_pressed)

func init(choices):
	var choice_number = 0
	for entry in choices:
		get_children()[choice_number].text = entry
		get_children()[choice_number].visible = true
		toggle_button(get_children()[choice_number],choice_number)
		choice_number += 1
	var last_button = get_children()[choice_number-1]
	last_button.last = true
	last_button.focus_neighbor_bottom = get_children()[0].get_path()
	position.y = (4-choice_number) * 80
	
	await shown
	get_children()[0].grab_focus()

func toggle_button(button,time : float):
	var actual_time : float = (time+0.5)/15
	var timer = Global.new_timer(actual_time)
	await timer.timeout
	var modulate_tween = create_tween()
	var target_pos = button.global_position
	button.global_position.y += 10
	modulate_tween.tween_property(button,"modulate",Color(1,1,1,1),0.3)
	modulate_tween.parallel().tween_property(button,"global_position",target_pos,0.3)
	await modulate_tween.finished
	if button.last: emit_signal("shown")

func on_pressed():
	var text_queue = textbox.text_queue
	var delete_list := []
	var lower_bound := 0
	var upper_bound := -1
	var index_entry = 0
	for entry in text_queue:
		if entry.has(question_tag) && entry[question_tag] == choice: lower_bound = index_entry
		if entry.has(question_tag) && entry[question_tag] != choice && entry[question_tag] == choice+1: upper_bound = index_entry-1
		if entry.has("Resume") && entry["Resume"] == question_tag:
			if upper_bound == -1: upper_bound = index_entry-1
			break
		index_entry += 1
	
	var point = 0
	for entry in text_queue:
		if entry.has("Resume") && entry["Resume"] == question_tag: break
		if point < lower_bound or point > upper_bound:
			delete_list.append(entry)
		point += 1
	
	for entry in delete_list: text_queue.erase(entry)
	textbox.text_queue = text_queue
	textbox.current_state = 0
	textbox.choosing = false
	
	get_viewport().gui_get_focus_owner().release_focus()
	for button in get_children():
		disappear_button(button)

func disappear_button(button):
	var tween := create_tween()
	tween.tween_property(button,"modulate",Color(1,1,1,0),0.1)
	await tween.finished
	button.visible = false
