extends RichTextLabel

func _process(_delta):
	if Global.debug:
		var target_name := &"none"
		if is_instance_valid(owner.target): target_name = owner.target.name.to_lower()
#		var rounded_tween = str(round(owner.raycast.target_position.x))
		var raycast = str(owner.raycast_length + owner.raycast_bonus_length)
		
		text = &"[center]"+owner.current_state+&"\n"+target_name+&"\n"+str(owner.change_states)+&"\n"+raycast+&"[/center]"

func _ready():
	add_to_group("debug")
	visible = false

func toggle_label():
	visible = !visible
