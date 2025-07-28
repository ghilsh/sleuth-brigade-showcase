extends Marker2D

@export var tag : int = 0

func _ready():
	add_to_group("entry")
	init()
	visible = false

func init():
	if tag == Global.entry_tag:
		for player in get_tree().get_nodes_in_group("player"):
			player.position = position
