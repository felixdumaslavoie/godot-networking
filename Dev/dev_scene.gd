extends Node


var instances = {}

# Constructor
func _init():
	var client =  load("res://Client/client.tscn").instantiate()
	var serveur = load("res://Serveur/serveur.tscn").instantiate()
	add_child(client)
	add_child(serveur)
	instances = {
		"serveur" : serveur, 
		"client" : client
	}

func _process(delta: float) -> void:
	ImGui.Begin("Hello world")
	ImGui.Text("Hello from imgui")
	ImGui.End()
