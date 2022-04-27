extends CharacterBody2D
class_name Player

const SPEED = 100.0

@onready var states = $state_manager
@onready var animation_player = $AnimationPlayer

var basic_attack : PackedScene = preload("res://Player/basic_attack.tscn")
var health = 3 :
	set(value):
		health = value
		$Networking.sync_character_health = value

signal hurt_player

func _ready():
	$Networking/MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	$Networking.sync_character_health = health
	
	position = $Networking.sync_position
	print("position: " + str(position))
	print("Sync_Position: " + str($Networking.sync_position) )
	
	states.init(self)

func _physics_process(delta):
	if not is_local_authority():
		if not $Networking.processed_position:
			position = $Networking.sync_position
			$AnimatedSprite2D.flip_h = $Networking.sync_character_h_flip
			$ProjectileDetector.position = $Networking.sync_character_projectile_detector
			
			states.change_state($Networking.sync_character_state)
			
			$Networking.processed_position = true
		velocity = $Networking.sync_velocity
		
		move_and_slide()
		return
	
	states.physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	if is_local_authority():
		states.input(event)

func attack_animation_finished() -> void:
	if is_local_authority():
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

func is_local_authority():
	return $Networking/MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()

func _on_projectile_detector_area_entered(area):
	emit_signal("hurt_player")
	if is_local_authority():
		health -= 1
		print("Health: " + str(health))
		print("Health on server: " + str($Networking.sync_character_health))
		if health <= 0:
			states.change_state(4)
			print("Died! Health: " + str(health))
			print("Died! Health on server: " + str($Networking.sync_character_health))
			print($state_manager.current_state)

#Gets called at the end of the Death animation in the AnimationPlayer node
func kill_player() -> void:
	if is_local_authority():
		queue_free()
