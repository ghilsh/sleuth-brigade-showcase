extends CharacterBody2D

func _on_area_body_entered(body):
	if body.is_in_group("enemy"):
		queue_free()
