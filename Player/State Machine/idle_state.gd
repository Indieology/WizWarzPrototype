extends BaseState


func input(event: InputEvent) -> int:
	if Input.is_action_pressed("attack"):
		return State.Attack
	elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
		return State.Walk
	
	return State.Null

func physics_process(delta: float) -> int:
	player.velocity = Vector2.ZERO
	get_parent().get_parent().get_node("Networking").sync_velocity = Vector2.ZERO
	player.move_and_slide()
	
	if player.health <= 0:
		return State.Death
	
	return State.Null

