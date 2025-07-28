extends CanvasLayer

@export var begin := false:
	set(_value):
		emit_signal("begin_battle")

signal begin_battle
