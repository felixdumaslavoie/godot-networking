# server_node.gd
class_name ServerNode
extends Node

var server = UDPServer.new()
var peers = []

const TIME_STEP : float = 0.035 # In sec
var time : float = Time.get_unix_time_from_system() 
var deltaTime : float = 0

var latestId : int = 0

var tick = 0

func createID() -> int :
	latestId += 1
	return latestId
	

func addNewClient(peer : PacketPeerUDP) -> Dictionary :
	
	var newPlayer : Player = load("res://Shared/player.tscn").instantiate()
	newPlayer.is_server = true
	newPlayer.z_index = -1
	add_child(newPlayer)
	
	var initPeer : Dictionary = {
		"id" : createID(),
		"socket": peer,
		"inputs": [],
		"Player": newPlayer
	}
	return initPeer

func _ready():
	server.listen(4242)
	

func _process(delta):
	tick += 1
	server.poll() # Important!
	if server.is_connection_available():
		var peer : PacketPeerUDP = server.take_connection()
		#var packet : PackedByteArray = peer.get_packet()
		peers.append(addNewClient(peer))
		var id = {}
		id["id"] = (latestId) 
		var packet = JSON.stringify(id).to_utf8_buffer()
	
		peer.put_packet(packet)
		print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_local_port()])
		#print("Received data: %s" % [packet.get_string_from_utf8()])
		# Reply so it knows we received the message.
		
		# Keep a reference so we can keep contacting the remote peer.
		
		
		
	# Do something with the connected peers.
	for i in range(0, peers.size()):
		# Update authoritative data 
		#var slicedInput = peers[i]["inputs"].pop_front() 
		#if (slicedInput != null):
		#	peers[i]["Player"].process_world_update(slicedInput)
			
		#print(peers[i]["socket"].get_packet())
		var packet = peers[i]["socket"].get_packet()
		if (packet):
			var json_string : Dictionary = {}
			
			if (JSON.parse_string(packet.get_string_from_utf8()) != null ):
				json_string = JSON.parse_string(packet.get_string_from_utf8())
				
				if (json_string != null):
					var data : Dictionary = json_string
					if data:
						if typeof(data) == TYPE_DICTIONARY:
							var receivedData = {
								"id": i,
								"time": data["time"],
								"sidemove": data["sidemove"],
								"upmove": data["upmove"],
								"viewangle_side": data["viewangle_side"],
								"viewangle_up": data["viewangle_up"],
								"buttons": data["buttons"],
							}
							peers[i]["inputs"].push_back(receivedData)
							
							#print(peers[i]["inputs"])
						else:
							print("Error parsing data from client")
							
					else:
						print("JSON Parse Error: ", data, " in ", json_string)
			
	#if time > timeStep, send authoritative data 
	deltaTime = Time.get_unix_time_from_system() - time
	
	if (deltaTime >= TIME_STEP):
		send_world_update()
		deltaTime = 0
		time = Time.get_unix_time_from_system()
	
	update_world()
	
func update_world():
	for i in range(0, peers.size()):
		var inputs = peers[i]["inputs"]
		
		if (inputs.size() > 0):
			var oldest_input : Dictionary = peers[i]["inputs"].pop_back()
			peers[i]["Player"].input_processing(oldest_input)
			
	
func get_peers_ids() -> Array:
	var peers_ids: Array = []
	for i in range(0, peers.size()):
		peers_ids.push_back(int(peers[i]["id"]))
	return peers_ids

func send_world_update():
	var world_update_data = {}
	var data : Dictionary = {
		"peers": get_peers_ids(),
	}
	for i in range(0, peers.size()):
			var packet = peers[i]["Player"].get_state()
			world_update_data[peers[i]["id"]] = packet
	
	world_update_data["data"] = data
	
	## Sending information
	for i in range(0, peers.size()):
		peers[i]["socket"].put_packet(JSON.stringify(world_update_data).to_utf8_buffer())
		
	
	 
func get_peers() -> Array : 
	return peers 
