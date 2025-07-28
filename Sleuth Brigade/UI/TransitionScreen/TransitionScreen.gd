extends CanvasLayer

@onready var screen := $ColorRect
var location : StringName

func _ready():
	screen.modulate = Color(1,1,1,0)
	var fadein_tween = create_tween()
	fadein_tween.tween_property(screen,"modulate",Color(1,1,1),0.25)
	
	await fadein_tween.step_finished
	
	Global.change_scene(location)
	get_tree().call_group("pause","unpause")
	
	var timer = Global.new_timer(0.1)
	
	await timer.timeout
	
	var fadeout_tween = create_tween()
	fadeout_tween.tween_property(screen,"modulate",Color(1,1,1,0),0.25)
	
	await fadeout_tween.step_finished
	
	queue_free()
