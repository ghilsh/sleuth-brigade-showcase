extends StaticBody2D

@onready var animation_player := $AnimationPlayer

func despawn_cones():
	var tween = create_tween()
	tween.tween_property($Sprite,"modulate",Color(1,1,1,0),0.15)
	await tween.finished
	queue_free()
