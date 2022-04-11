extends RigidDynamicBody2D


func _process(delta):
	if $Timeout.is_stopped():
		queue_free()
	
