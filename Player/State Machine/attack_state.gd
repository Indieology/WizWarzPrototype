extends BaseState


func physics_process(delta: float) -> int:
	if get_parent().get_parent().get_node("AttackDelay").is_stopped():
			get_parent().get_parent().get_node("AttackDelay").start()
			
	if get_parent().get_parent().get_node("AnimationPlayer").is_playing() == false:
		return State.Idle
	if player.health <= 0:
		return State.Death
	return State.Null
	
