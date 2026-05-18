# res://estados/EstadoPreparacion.gd (versión simple con timer)
extends State
class_name EstadoPreparacion

var nivel_actual: Node
var spawner: Node

func entrar() -> void:
	print("Estado: Preparación - Coloca tus torretas")
	
	# cambiar la escena
	get_tree().change_scene_to_file("res://node_3d.tscn")
	
	# esperar 0.2 segundos para que la escena se cargue
	await get_tree().create_timer(0.2).timeout
	
	if get_tree().current_scene and get_tree().current_scene.name == "node_3d":
		nivel_actual = get_tree().current_scene
		spawner = _buscar_spawner(nivel_actual)
		
		if spawner:
			spawner.estado_generador = false
			print("Modo preparación activado. Coloca torretas.")
	else:
		print("Error: No se pudo cargar node_3d.tscn")

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

func actualizar(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		transicion_solicitada.emit("Invasion")

func salir() -> void:
	print("Terminando preparación")
