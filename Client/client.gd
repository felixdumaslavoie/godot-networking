# client_node.gd
class_name ClientNode
extends Node

var udp = PacketPeerUDP.new()
var connected = false

const HOST = "127.0.0.1"
const PORT = 4242

func _ready():
	udp.connect_to_host(HOST, PORT)

func _process(delta):
	if !connected:
		# Try to contact server
		udp.put_packet("The answer is... 42!".to_utf8_buffer())
	if udp.get_available_packet_count() > 0:
		print("Connected: %s" % udp.get_packet().get_string_from_utf8())
		connected = true


func send_input(inputs : Dictionary):
	if connected: 
		var serialized_inputs = JSON.stringify(inputs)
		udp.put_packet(serialized_inputs.to_utf8_buffer())
		
		
