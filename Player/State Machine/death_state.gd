extends BaseState


func physics_process(delta: float) -> int:
	player.velocity = Vector2.ZERO
	get_parent().get_parent().get_node("Networking").sync_velocity = Vector2.ZERO
	print("Player is inside of the death state")
	
	
	return State.Null

func exit() -> void:
	pass
	#player.queue_free()
