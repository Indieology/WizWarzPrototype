extends RigidDynamicBody2D

func _ready():
	if $AnimatedSprite2D.flip_h == true:
		$PlayerDetector.position = Vector2 (5,5)


func _process(delta):
	if $Timeout.is_stopped():
		queue_free()

func _on_player_detector_area_entered(area):
		var detected_object = area.get_parent()
		if detected_object.has_method("take_damage"):
			detected_object.take_damage(1)
			print("calling take_damage() from attack script")
	
