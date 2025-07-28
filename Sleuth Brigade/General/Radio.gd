extends Node

var current_audio : Dictionary = {&"music":&"",&"ambience":&""}
var tweeners := []

func change_stream(player : StringName, new_audio : StringName):
	kill_tweeners()
	if new_audio == &"fadeout":
		fadeout()
		return
	var audio = get_node(NodePath(player))
	if new_audio != &"none":
		var prefix = get_lookup(player)
		var file = load("res://Assets/Audio/"+prefix+new_audio+".ogg")
		audio.stream = file
		current_audio[player] = new_audio
		audio.play()
	else:
		audio.stream = null
		current_audio[player] = &""

func change_volume(bus_name : StringName, new_value : float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(new_value/100))

func get_lookup(player):
	match player:
		&"ambience": return "Ambience/amb_"
		&"music": return "Music/mus_"

func fadeout(time := 5.0):
	var fade_tween := create_tween()
	tweeners.append(fade_tween)
	fade_tween.tween_property($music,"volume_db",-40.0,time)
	await fade_tween.finished
	$music.stream = null
	$music.volume_db = 0
	current_audio[&"music"] = &""

func kill_tweeners():
	$music.volume_db = 0
	for tween in tweeners: tween.kill()
