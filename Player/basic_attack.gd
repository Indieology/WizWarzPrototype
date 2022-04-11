extends RigidDynamicBody2D


func _ready():
	if $AnimatedSprite2D.flip_h == true:
		$PlayerDetector.position = Vector2 (5,5)



func _process(delta):
	if $Timeout.is_stopped():
		queue_free()
