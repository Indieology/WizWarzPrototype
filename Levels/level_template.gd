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
	
	$Players.add_child(p)
	random.randomize()
	var random_number = random.randi_range(-100, 100)
	p.position = Vector2(random_number, random_number)
	p.connect("hurt_player", hurt_player, [id])

func destroy_player(id : int) -> void:
	$Players.get_node(str(id)).queue_free()

func hurt_player(id):
	print("player " + str(id) + " has been hurt")
	var this_player = $Players.get_node(str(id))
	this_player.health -= 1
	if this_player.health <= 0:
		destroy_player(id)
	

@rpc(any_peer)
func player_projectile():
	rpc("spawn_projectile")
