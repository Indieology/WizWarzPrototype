extends CharacterBody2D
class_name Player

const SPEED = 100.0

var basic_attack : PackedScene = preload("res://Player/basic_attack.tscn")


func _ready():
	$Networking/MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

func _physics_process(delta):
	if not is_local_authority():
		if not $Networking.processed_position:
			position = $Networking.sync_position
			$AnimatedSprite2D.flip_h = $Networking.sync_character_h_flip
			$AnimationPlayer.play($Networking.sync_character_animation)
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
			
			rpc_id(1, "spawn_projectile")
@rpc(any_peer)
func spawn_projectile():
	var attack_scene = basic_attack.instantiate()
	var attack_sprite = attack_scene.get_node("AnimatedSprite2D")
	get_tree().root.get_node("TestLevel/Projectiles").add_child(attack_scene)
	#get_parent().get_parent().get_node("Projectiles").add_child(attack_scene)
	if $AnimatedSprite2D.flip_h:
		attack_scene.position = position + Vector2(-5,0)
		attack_scene.apply_impulse(Vector2(-200,0))
		attack_sprite.flip_h = true
	else:
		attack_scene.position = position + Vector2(20,0)
		attack_scene.apply_impulse(Vector2(200,0))
		attack_sprite.flip_h = false

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
		
	elif velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		$Networking.sync_character_h_flip = $AnimatedSprite2D.flip_h 
		

func is_local_authority():
	return $Networking/MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()
