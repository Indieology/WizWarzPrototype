extends BaseState


func physics_process(delta: float) -> int:
	if get_parent().get_parent().get_node("AttackDelay").is_stopped():
			get_parent().get_parent().get_node("AttackDelay").start()
			get_parent().get_parent().get_node("Networking").sync_character_animation = "Attack"
			
	if get_parent().get_parent().get_node("AnimationPlayer").is_playing() == false:
		return State.Idle
	return State.Null
	
