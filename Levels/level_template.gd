extends Node2D

@export
var PlayerScene = preload("res://Player/player.tscn")
var Fireball = preload("res://Player/basic_attack.tscn")

var random = RandomNumberGenerator.new()

func _enter_tree():
	#Start the server if Godot is passed the --server argument
	#Create client otherwise
	if "--server" in OS.get_cmdline_args():
		start_network(true)
	else:
		start_network(false)

func start_network(server: bool) -> void:
	var peer = ENetMultiplayerPeer.new()
	if server:
		#Listen to peer connections, create or destory players for them. 
		multiplayer.peer_connected.connect(self.create_player)
		multiplayer.peer_disconnected.connect(self.destroy_player)
		
		peer.create_server(4242)
		print('server listening on localhost 4242')
	else:
		peer.create_client("localhost", 4242)
	
	multiplayer.set_multiplayer_peer(peer)

func create_player(id : int) -> void:
	#Instantiate a new player for this client
	var p = PlayerScene.instantiate()
	
	#Set the unique name for player, so we can calculate local authority
	p.name = str(id)
	
	random.randomize()
	var random_number = random.randi_range(-12, 12)
	p.get_node("Networking").sync_position = Vector2(random_number, random_number)
	print("position printing from level script: " + str(p.get_node("Networking").sync_position))
	
	p.connect("hurt_player", hurt_player, [id])
	
	$Players.add_child(p)

func destroy_player(id : int) -> void:
	$Players.get_node(str(id)).queue_free()

func hurt_player(id):
	print("player " + str(id) + " has been hurt")
	var this_player = $Players.get_node(str(id))
	
	this_player.health -= 1
	this_player.get_node("Networking").sync_character_health = this_player.health
	if this_player.health <= 0:
		this_player.get_node("state_manager").change_state(4)
		this_player.get_node("Networking").sync_character_animation = "Death"
		print("Health: " + str(this_player.health))
		print("Health on server: " + str(this_player.get_node("Networking").sync_character_health))
		print(this_player.get_node("state_manager").current_state)
	

@rpc(any_peer)
func player_projectile():
	rpc("spawn_projectile")


