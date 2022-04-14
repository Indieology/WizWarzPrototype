extends BaseState


func physics_process(delta: float) -> int:
	player.velocity = Vector2.ZERO
	get_parent().get_parent().get_node("Networking").sync_velocity = Vector2.ZERO
	
	await player.animation_player.animation_finished
	player.queue_free()
	
	return State.Null
	
