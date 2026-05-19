extends Node

signal estado_cambiado(nuevo_estado)

enum EstadoJuego { MENU, PREPARACION, INVASION, VICTORIA, DERROTA }
var estado_actual: EstadoJuego = EstadoJuego.MENU
var nivel_actual: Node = null
var puntaje_actual: int = 0  # <--- NUEVO

func _ready():
	print("GameManager listo. Estado inicial: MENU")

func cambiar_estado(nuevo_estado: EstadoJuego):
	estado_actual = nuevo_estado
	estado_cambiado.emit(nuevo_estado)
	print("Estado cambiado a: ", estado_actual)
	
	match estado_actual:
		EstadoJuego.MENU:
			get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
			nivel_actual = null
			puntaje_actual = 0
		
		EstadoJuego.PREPARACION:
			if nivel_actual == null or not is_instance_valid(nivel_actual):
				get_tree().change_scene_to_file("res://scenes/niveles.tscn")
			else:
				_reiniciar_spawner()
		
		EstadoJuego.INVASION:
			_iniciar_invasion()
		
		EstadoJuego.VICTORIA:
			_mostrar_pantalla_final("victoria")
		
		EstadoJuego.DERROTA:
			_mostrar_pantalla_final("derrota")

func _reiniciar_spawner():
	print("Reiniciando spawner...")
	var spawner = _buscar_spawner(nivel_actual)
	if spawner:
		spawner.estado_generador = false
		spawner.enemigos_generados = 0
		spawner.enemigos_vivos = 0
		print("Spawner reiniciado. Listo para nueva invasión.")

func _iniciar_invasion():
	print("Iniciando invasión...")
	if not nivel_actual or not is_instance_valid(nivel_actual):
		nivel_actual = get_tree().current_scene
	
	var spawner = _buscar_spawner(nivel_actual)
	if spawner:
		# conectar señal de victoria
		if not spawner.todas_hormigas_muertas.is_connected(_on_victoria):
			spawner.todas_hormigas_muertas.connect(_on_victoria)
		
		spawner.enemigos_generados = 0
		spawner.enemigos_vivos = 0
		spawner.inicio_generacion()
		print("¡Invasión comenzada!")
	else:
		print("Error: No se encontró el Spawner")
	
	# conectar señal de derrota desde la reina
	var reina = _buscar_reina(nivel_actual)
	if reina and not reina.reina_muerta.is_connected(_on_derrota):
		reina.reina_muerta.connect(_on_derrota)

func _on_victoria():
	print("¡Victoria! Todas las hormigas eliminadas")
	cambiar_estado(EstadoJuego.VICTORIA)

func _on_derrota():
	print("¡Derrota! La reina ha muerto")
	cambiar_estado(EstadoJuego.DERROTA)

func _mostrar_pantalla_final(_tipo: String):
	get_tree().change_scene_to_file("res://scenes/menu/pantalla_final.tscn")

func _buscar_spawner(nodo: Node) -> Node:
	if not nodo:
		return null
	for hijo in nodo.get_children():
		if hijo.has_method("siguiente_generacion_enemigo"):
			return hijo
		var encontrado = _buscar_spawner(hijo)
		if encontrado:
			return encontrado
	return null

func _buscar_reina(nodo: Node) -> Node:
	if not nodo:
		return null
	for hijo in nodo.get_children():
		if hijo.is_in_group("reina"):
			return hijo
		var encontrado = _buscar_reina(hijo)
		if encontrado:
			return encontrado
	return null

func sumar_puntaje(puntos: int):
	puntaje_actual += puntos
	print("Puntaje acumulado: ", puntaje_actual)
