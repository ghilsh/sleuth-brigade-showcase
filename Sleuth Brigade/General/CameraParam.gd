extends ReferenceRect

@export var music : StringName = &"same"
@export var ambience : StringName = &"same"
@export var music_volume : float = -1.0
@export var ambience_volume : float = -1.0

var same_music := false

func _ready():
	add_to_group(&"param")
	if music == &"same": 
		same_music = true
		music = get_parent().get_parent().music
	if ambience == &"same": ambience = get_parent().get_parent().ambience
	if music_volume == -1.0: music_volume = get_parent().get_parent().music_volume
	if ambience_volume == -1.0: ambience_volume = get_parent().get_parent().ambience_volume
