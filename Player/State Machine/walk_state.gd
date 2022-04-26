extends BaseState

func input(event: InputEvent) -> int:
	if Input.is_action_just_pressed("attack"):
		return State.Attack
	
	return State.Null

func physics_process(delta: float) -> int:
	var move_direction = Vector2()
	
	if Input.is_action_pressed("move_down"):
		move_direction += Vector2.DOWN
	if Input.is_action_pressed("move_left"):
		move_direction += Vector2.LEFT
	if Input.is_action_pressed("move_right"):
		move_direction += Vector2.RIGHT
	if Input.is_action_pressed("move_up"):
		move_direction += Vector2.UP
	
	player.velocity = move_direction.normalized() * player.SPEED
	get_parent().get_parent().get_node("Networking").sync_velocity = player.velocity
	get_parent().get_parent().get_node("Networking").sync_position = player.position
	player.move_and_slide()
	
	if player.velocity.x < 0:
		get_parent().get_parent().get_node("AnimatedSprite2D").flip_h = true
		get_parent().get_parent().get_node("Networking").sync_character_h_flip = true
		get_parent().get_parent().get_node("ProjectileDetector").position = Vector2(6,0)
		get_parent().get_parent().get_node("Networking").sync_character_projectile_detector = Vector2(6,0)
	elif player.velocity.x > 0:
		get_parent().get_parent().get_node("AnimatedSprite2D").flip_h = false
		get_parent().get_parent().get_node("Networking").sync_character_h_flip = false 
		get_parent().get_parent().get_node("ProjectileDetector").position = Vector2(-2,0)
		get_parent().get_parent().get_node("Networking").sync_character_projectile_detector = Vector2(-2,0)
	
	if player.velocity == Vector2.ZERO:
		return State.Idle
	
	if player.health <= 0:
		return State.Death
	
	return State.Null

func enter() -> void:
	player.animation_player.play(animation_name)
	get_parent().get_parent().get_node("Networking").sync_character_state = State.Walk
