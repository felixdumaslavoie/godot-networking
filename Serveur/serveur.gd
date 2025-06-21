# server_node.gd
class_name ServerNode
extends Node

var server = UDPServer.new()
var peers = []

const updateRate : int = 30 # In Hz

var latestId : int = 0

func createID() -> int :
	latestId += 1
	return latestId
	


func addNewClient(peer : PacketPeerUDP) -> Dictionary :
	var initPeer = {
		"id" : createID(),
		"socket": peer,
	}
	return initPeer

func _ready():
	server.listen(4242)

func _process(delta):
	server.poll() # Important!
	if server.is_connection_available():
		var peer : PacketPeerUDP = server.take_connection()
		var packet : PackedByteArray = peer.get_packet()
	
		print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_local_port()])
		print("Received data: %s" % [packet.get_string_from_utf8()])
		# Reply so it knows we received the message.
		peer.put_packet(packet)
		# Keep a reference so we can keep contacting the remote peer.
		peers.append(addNewClient(peer))

	for i in range(0, peers.size()):
		var packet = peers[0]["socket"].get_packet()
		if (packet):			
			var json_string : Dictionary = {}

			if (JSON.parse_string(packet.get_string_from_utf8()) != null ):
			
				json_string = JSON.parse_string(packet.get_string_from_utf8())
			
				if (json_string != null):
					var data : Dictionary = json_string
					if data:
						var data_received = data
						if typeof(data_received) == TYPE_DICTIONARY:
							print(data_received)
						else:
							print("Error parsing data from client")
							
					else:
						print("JSON Parse Error: ", data, " in ", json_string)
				
				# Do something with the connected peers.


func get_peers() -> Array : 
	return peers 
