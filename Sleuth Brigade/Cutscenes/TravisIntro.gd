extends "res://Cutscenes/Cutscene.gd"

@onready var hitter := $BatPivot/Hitter
@onready var sprite := $SpritePivot/Sprite

func _ready():
	sprite.hframes = Global.get_frames(sprite,&"travis")
	super()

func initiate_cutscene():
	visible = true
	get_parent().visible = true
	$Shadow.visible = true
	$SpritePivot.visible = true
	Global.player_facing = Vector2(1,1)
	position = player.position
	$AnimationPlayer.animation_finished.connect(anim_fin)
	$AnimationPlayer.play(&"anim")
	player.active = false
	player.visible = false

func anim_fin(_anim): # this code sucks so bad
	hitter.play("ready")
	var ready_timer = Global.new_timer(0.25)
	await ready_timer.timeout
	hitter.play("hit")
	$SpritePivot/Sprite.flip_h = true
	$Sounds/Swing.play()
	await hitter.animation_finished
	$SpritePivot/Sprite.flip_h = false
	$BatPivot.scale = Vector2(1,-1)
	hitter.play("hit")
	$Sounds/Swing.play()
	await hitter.animation_finished
	finish()

func finish():
	player.active = true
	player.visible = true
	Global.plot = 1
	queue_free()
