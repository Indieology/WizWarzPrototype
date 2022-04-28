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
	
	#I see what you were saying about signals being like social media posts, but how would I connect this signal
	#To a function in a differnet script? It just seems convient to connect signals here, but that means im
	#limited to only functions in this script?
	p.connect("hurt_player", hurt_player, [id])
	
	$Players.add_child(p)

func destroy_player(id : int) -> void:
	$Players.get_node(str(id)).queue_free()

func hurt_player(id):
	#Is this where I would update health UI?
	pass

@rpc(any_peer)
func player_projectile():
	rpc("spawn_projectile")


