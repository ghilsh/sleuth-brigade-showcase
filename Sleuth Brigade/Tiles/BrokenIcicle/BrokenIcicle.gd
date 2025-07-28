extends Node2D

@onready var sprite_pivot := $SpritePivot
@onready var sprite := $SpritePivot/Sprite

var movement_direction := Vector2.ZERO

func _ready():
	movement_direction *= 10
	var tween = create_tween()
	tween.tween_property(sprite,"modulate",Color(1,1,1,0),0.5)
	tween.parallel().tween_property(sprite_pivot,"position",sprite_pivot.position+movement_direction,0.5)
