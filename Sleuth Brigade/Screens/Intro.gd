extends Node2D

@onready var clouds := $Clouds
@onready var helicopter_pivot := $HelicopterPivot
@onready var travis_sprite := $HelicopterPivot/Helicopter/Sprites/Travis

var speed := 4
const FLYINGSPEED = 150

func _ready():
	travis_sprite.hframes = Global.get_frames(travis_sprite,&"travis")
	Radio.change_stream(&"music",&"none")
	Radio.change_stream(&"ambience",&"highwinds")
	Radio.change_volume(&"music",100)
	Radio.change_volume(&"ambience",5)
	Global.plot = 0
	Global.entry_tag = 0
	
	var text_timer = Global.new_timer(4.5)
	await text_timer.timeout
	
	var enter_tween = create_tween()
	enter_tween.tween_property(helicopter_pivot,"position",Vector2(576,helicopter_pivot.position.y),1.5).set_ease(Tween.EASE_OUT)
	enter_tween.parallel().tween_property(self,"speed",FLYINGSPEED,1.5).set_ease(Tween.EASE_IN)
	enter_tween.parallel().tween_property($Sounds/Helicopter,"volume_db",-10,1.5).set_ease(Tween.EASE_IN)
	
	var action_timer = Global.new_timer(3.0)
	await action_timer.timeout
	
	$HelicopterPivot/Helicopter/ActionAnim.play("action")
	
	await $HelicopterPivot/Helicopter/ActionAnim.animation_finished
	
	Global.fade_scene("res://Screens/Rooms/RoomForest.tscn")

func _process(delta):
	for cloud in clouds.get_children():
		cloud.global_position.x -= ((speed*(cloud.scale.x + cloud.scale.y))) * delta
