extends State
class_name EstadoInvasion

var spawner: Node

func entrar() -> void:
	print("Estado: Invasión - ¡Las hormigas atacan!")
	
	if get_tree().current_scene.name != "node_3d":
		print("Error: No se encuentra el nivel")
		return
	
	spawner = _buscar_spawner(get_tree().current_scene)
	
	if spawner:
		if not spawner.oleada_completada.is_connected(_on_oleada_completada):
			spawner.oleada_completada.connect(_on_oleada_completada)
		
		spawner.estado_generador = true
		spawner.enemigos_generados = 0
		spawner.siguiente_generacion_enemigo()
		print("¡Invasión comenzada!")
	else:
		print("Error: No se encontró el Spawner")

func _buscar_spawner(nodo: Node) -> Node:
	if not nodo:
		return null
		
	for hijo in nodo.get_children():
		if hijo is Spawner:
			return hijo
		var encontrado = _buscar_spawner(hijo)
		if encontrado:
			return encontrado
	return null

func _on_oleada_completada() -> void:
	print("Oleada completada. Volviendo a preparación...")
	transicion_solicitada.emit("Preparacion")

func actualizar(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		transicion_solicitada.emit("Menu")

func salir() -> void:
	if spawner and spawner.oleada_completada.is_connected(_on_oleada_completada):
		spawner.oleada_completada.disconnect(_on_oleada_completada)
