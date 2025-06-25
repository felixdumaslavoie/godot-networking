extends Node

var instances = {}

var t = 0.0

var camSpeed = 20

const number_of_clients : int = 2

var client : int = 1

# Constructor
func _init():
	Engine.max_fps = 60
	var clientControle : ClientNode =  load("res://Client/client.tscn").instantiate()
	var client2 : ClientNode =  load("res://Client/client.tscn").instantiate()
	var serveur : ServerNode = load("res://Serveur/serveur.tscn").instantiate()
	
	clientControle.set_client()
	
	add_child(clientControle)
	add_child(client2)
	add_child(serveur)
	
	instances = {
		"serveur" : serveur, 
		"client1" : clientControle,
		"client2" : client2
	}
	
	
func switch_client():
	if (client == 1):
		instances[str("client"+ str(client))].remove_client()
		instances[str("client"+ str(client+ 1))].set_client()
		client = 2
	elif (client == 2):
		instances[str("client"+ str(client))].remove_client()
		instances[str("client"+ str(client - 1))].set_client()
		client = 1
		
	
func get_input( delta : float):
	if Input.is_action_pressed("zoom_in"):
		$Camera2D.zoom.x = lerp($Camera2D.zoom.x, $Camera2D.zoom.x + 0.25, t)
		$Camera2D.zoom.y  = lerp($Camera2D.zoom.y, $Camera2D.zoom.y + 0.25, t)
	if Input.is_action_pressed("zoom_out"):
		$Camera2D.zoom.x = lerp($Camera2D.zoom.x, $Camera2D.zoom.x - 0.25, t)
		$Camera2D.zoom.y  =  lerp($Camera2D.zoom.y, $Camera2D.zoom.y - 0.25, t)
		
	if Input.is_action_just_pressed("switch_client"):
		switch_client()
	
	var input_direction = Input.get_vector("left", "right", "up", "down")
	$Camera2D.position += input_direction * camSpeed * delta
	

func _process(delta: float) -> void:
	
	ImGui.Begin("FPS")
	ImGui.Text(str(Engine.get_frames_per_second()).pad_decimals(2))
	ImGui.End()
	ImGui.Begin("Peers")
	for peer in instances["serveur"].get_peers():
		
		ImGui.SetNextItemOpen(true)
		if ImGui.CollapsingHeader( "Client " + str(peer["id"]) ):
			if(instances[str("client"+ str(peer["id"]))].is_client()):
				ImGui.LabelText(str(int(instances[str("client"+ str(peer["id"]))].ping)), "ping: ")
			ImGui.LabelText(  str(peer["socket"].get_packet_ip()) + ":"+ str(peer["socket"].get_local_port()), "socket: ")
			ImGui.LabelText(  str(instances[str("client"+ str(peer["id"]))].getClientPlayerLocation()), "Position client (x,y) " + ":" )
			ImGui.LabelText(  str(peer["Player"].get_location()), "Position serveur (x,y) " + ":" )
			
	ImGui.End()
	
	get_input(delta)
	
func _physics_process(delta: float) -> void:
	t += delta * 0.01
