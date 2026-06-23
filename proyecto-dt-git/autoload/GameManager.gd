extends Node

signal estado_cambiado(nuevo_estado)

enum EstadoJuego { MENU, PREPARACION, INVASION, VICTORIA, DERROTA, SPLASHSCREEN }
var estado_actual: EstadoJuego = EstadoJuego.MENU
var nivel_actual: Node = null

var celdas_cesped: Array[Vector2i] = []
var celda_ocupada: Array[Vector2i] = []

func _ready():
	print("GameManager listo. Estado inicial: MENU")
	await get_tree().process_frame
	cambiar_estado(EstadoJuego.SPLASHSCREEN)

func cambiar_estado(nuevo_estado: EstadoJuego):
	estado_actual = nuevo_estado
	estado_cambiado.emit(nuevo_estado)
	print("Estado cambiado a: ", estado_actual)
	
	match estado_actual:
		EstadoJuego.SPLASHSCREEN:
			get_tree().call_deferred("change_scene_to_file", "res://scenes/splash_screen.tscn")
			nivel_actual = null
			AudioManager.play_menu_music()
		EstadoJuego.MENU:
			get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/menu.tscn")
			nivel_actual = null
			AudioManager.play_menu_music()
		
		EstadoJuego.PREPARACION:
			if nivel_actual == null or not is_instance_valid(nivel_actual):
				get_tree().call_deferred("change_scene_to_file", "res://scenes/niveles.tscn")
			else:
				_reiniciar_spawner()
		
		EstadoJuego.INVASION:
			pass
		
		EstadoJuego.VICTORIA:
			_mostrar_pantalla_final()
			AudioManager.stop_music_with_fade()
		
		EstadoJuego.DERROTA:
			_mostrar_pantalla_final()
			AudioManager.stop_music_with_fade()

func _reiniciar_spawner():
	print("Reiniciando spawner...")
	var spawner = _buscar_spawner(nivel_actual)
	if spawner:
		spawner.estado_generador = false
		spawner.enemigos_generados = 0
		spawner.enemigos_vivos = 0
		print("Spawner reiniciado. Listo para nueva invasión.")

func _iniciar_invasion(ruta = null):
	print("Iniciando invasión...")
	if not nivel_actual or not is_instance_valid(nivel_actual):
		nivel_actual = get_tree().current_scene
	
	var spawner = _buscar_spawner(nivel_actual)
	if not spawner:
		print("Error: No se encontró el Spawner")
		return
	
	if ruta == null:
		if spawner.has_method("get_ruta") and spawner.ruta_a_seguir:
			ruta = spawner.ruta_a_seguir
		else:
			print("Error: No se proporcionó ruta y el spawner no tiene una configurada")
			return
	
	spawner.configurar_ruta(ruta)
	
	if not spawner.todas_hormigas_muertas.is_connected(_on_victoria):
		spawner.todas_hormigas_muertas.connect(_on_victoria)
	
	spawner.enemigos_generados = 0
	spawner.enemigos_vivos = 0
	spawner.inicio_generacion()
	print("¡Invasión comenzada!")
	
	var reina = _buscar_reina(nivel_actual)
	if reina and not reina.reina_muerta.is_connected(_on_derrota):
		reina.reina_muerta.connect(_on_derrota)

func _on_victoria():
	print("¡Victoria! Todas las hormigas eliminadas")
	cambiar_estado(EstadoJuego.VICTORIA)

func _on_derrota():
	print("¡Derrota! La reina ha muerto")
	cambiar_estado(EstadoJuego.DERROTA)

func _mostrar_pantalla_final():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/pantalla_final.tscn")

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

func registrar_cesped(celdas: Array[Vector2i]):
	celdas_cesped = celdas
	celda_ocupada = []
	
func es_cesped(pos_mundo: Vector3):
	var celda = Vector2i(roundi(pos_mundo.x), roundi(pos_mundo.z))
	return celdas_cesped.has(celda) and not celda_ocupada.has(celda)
	
func ocupar_celda(pos_mundo: Vector3):
	var celda = Vector2i(roundi(pos_mundo.x), roundi(pos_mundo.z))
	if not celda_ocupada.has(celda):
		celda_ocupada.append(celda)
