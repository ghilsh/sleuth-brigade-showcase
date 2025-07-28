extends Node2D

@onready var sprite := $SpritePivot/Sprite

func _ready():
	sprite.hframes = Global.get_frames(sprite,&"doug")
