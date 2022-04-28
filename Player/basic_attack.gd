extends RigidDynamicBody2D

signal hurt_player

func _ready():
	if $AnimatedSprite2D.flip_h == true:
		$PlayerDetector.position = Vector2 (5,5)


func _process(delta):
	if $Timeout.is_stopped():
		queue_free()

func _on_player_detector_area_entered(area):
		var detected_object = area.get_parent()
		emit_signal("hurt_player", detected_object)
	
