extends Node




# Constructor
func _init():
	var client =  load("res://Code/Client/client.tscn").instantiate()
	var serveur = load("res://Code/Serveur/serveur.tscn").instantiate()
	add_child(client)
	add_child(serveur)
	


func _process(delta: float) -> void:
	#ImGui.Begin("Hello world")
	#ImGui.Text("Hello from ImGui!!")
	#ImGui.End()
	pass
