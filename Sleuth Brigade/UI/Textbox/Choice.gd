extends Button

@export var tag := 0

var last := false

func _ready():
	pressed.connect(on_pressed)

func on_pressed():
	get_parent().choice = tag
