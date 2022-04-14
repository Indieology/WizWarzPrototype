extends BaseState


func physics_process(delta: float) -> int:
	if get_parent().get_parent().get_node("AttackDelay").is_stopped():
			get_parent().get_parent().get_node("AttackDelay").start()
			get_parent().get_parent().get_node("Networking").sync_character_animation = "Attack"
			
			#I would like to wait for the attack animation to finish playing before launching projectile
			#But this throws an error
			await player.animation_player.animation_finished
			
			#How do i call this RPC in our player script from our attack_state script?
			rpc_id(1, "spawn_projectile_server")
			
	return State.Idle
	
