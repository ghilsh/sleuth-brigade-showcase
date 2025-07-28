extends AudioStreamPlayer

@export var minim := 8
@export var maxim := 13

func play_varied():
	pitch_scale = randi_range(minim,maxim) * 0.1
	play()
