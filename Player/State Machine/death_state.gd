extends BaseState


func physics_process(delta: float) -> int:
	player.velocity = Vector2.ZERO
	get_parent().get_parent().get_node("Networking").sync_velocity = Vector2.ZERO
	
	
	return State.Null
	
