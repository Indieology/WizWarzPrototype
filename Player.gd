extends CharacterBody2D
class_name Player

var health = 3

const SPEED = 100.0

var basic_attack : PackedScene = preload("res://Player/basic_attack.tscn")

signal hurt_player

func _ready():
	$Networking/MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	
	position = $Networking.sync_position
	print("position: " + str(position))
	print("Sync_Position: " + str($Networking.sync_position) )

func _physics_process(delta):
	if not is_local_authority():
		if not $Networking.processed_position:
			position = $Networking.sync_position
			$AnimatedSprite2D.flip_h = $Networking.sync_character_h_flip
			$AnimationPlayer.play($Networking.sync_character_animation)
			$ProjectileDetector.position = $Networking.sync_character_projectile_detector
			$Networking.processed_position = true
		velocity = $Networking.sync_velocity
		
		move_and_slide()
		return
	
	get_player_input()
	animate_player()
	move_and_slide()
	
	$Networking.sync_position = position
	$Networking.sync_velocity = velocity
	
func get_player_input():
	var move_direction = Vector2()
	
	if Input.is_action_pressed("move_down"):
		move_direction += Vector2.DOWN
	if Input.is_action_pressed("move_left"):
		move_direction += Vector2.LEFT
	if Input.is_action_pressed("move_right"):
		move_direction += Vector2.RIGHT
	if Input.is_action_pressed("move_up"):
		move_direction += Vector2.UP
	velocity = move_direction.normalized() * SPEED

	
	if Input.is_action_just_pressed("attack"):
		if $AttackDelay.is_stopped():
			$AttackDelay.start()
			$AnimationPlayer.play("Attack")
			$Networking.sync_character_animation = "Attack"
			
			rpc_id(1, "spawn_projectile_server")

@rpc(any_peer)
func spawn_projectile_server():
	# TODO consider adding the path to the attack you want.
	# That way different attacks could be triggered by just changing one argument :)
	
	if not multiplayer.is_server():
		print('Client ' + str(multiplayer.get_remote_sender_id()) + ' told me to shoot. I should report them for cheating!')
		return
	# Validate the correct person has triggered this RPC
	if str(name).to_int() != multiplayer.get_remote_sender_id():
		print('Client ' + str(multiplayer.get_remote_sender_id()) + ' is trying to have player ' + str(name) + ' shoot. They are cheating!')
		return
	
	# Validate that the player is allowed to attack
	# This should be done here on the server to prevent cheating.
	# It should also be done client-side, to save us an RPC call for good clients :)
	if not $AttackDelay.is_stopped():
		return

	var pos : Vector2
	var impulse : Vector2
	if $AnimatedSprite2D.flip_h:
		pos = position + Vector2(-7,0)
		impulse = Vector2(-225,0)
	else:
		pos = position + Vector2(20,0)
		impulse = Vector2(225,0)
	
	# Call all clients to make them spawn the projectile. This also runs for us (the server)
	rpc('spawn_projectile_clients', pos, impulse, $AnimatedSprite2D.flip_h)

@rpc(call_local)
func spawn_projectile_clients(position : Vector2, impulse : Vector2, sprite_flipped : bool):
	# TODO consider passing a String in here with the res:// path to the attack. See TODO on _server method
	
	# Validation
	if 1 != multiplayer.get_remote_sender_id(): # This shouldn't be possible, @rpc should block it
		print(multiplayer.get_remote_sender_id() + ' is trying to cheat!')
		return

	var attack_scene = basic_attack.instantiate()
	var attack_sprite = attack_scene.get_node("AnimatedSprite2D")
	get_tree().root.get_node("TestLevel/Projectiles").add_child(attack_scene)
	attack_scene.position = position
	attack_scene.apply_impulse(impulse)
	attack_sprite.flip_h = sprite_flipped
	if sprite_flipped:
		attack_sprite.get_parent().get_node("PlayerDetector").position = Vector2(-9,-1)

func animate_player():
	if velocity == Vector2.ZERO and $AnimationPlayer.get_current_animation() != "Attack":
		$AnimationPlayer.play("Idle")
		$Networking.sync_character_animation = "Idle"
	elif $AnimationPlayer.get_current_animation() != "Attack":
		$AnimationPlayer.play("Walk")
		$Networking.sync_character_animation = "Walk"
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
		$Networking.sync_character_h_flip = $AnimatedSprite2D.flip_h
		$ProjectileDetector.position = Vector2(6,0)
		$Networking.sync_character_projectile_detector = $ProjectileDetector.position
	elif velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		$Networking.sync_character_h_flip = $AnimatedSprite2D.flip_h 
		$ProjectileDetector.position = Vector2(-2,0)
		$Networking.sync_character_projectile_detector = $ProjectileDetector.position

func is_local_authority():
	return $Networking/MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()




func _on_projectile_detector_area_entered(area):
	emit_signal("hurt_player")
