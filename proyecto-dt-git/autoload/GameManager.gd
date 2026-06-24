extends Node

signal estado_cambiado(nuevo_estado)

enum EstadoJuego { MENU, PREPARACION, INVASION, VICTORIA, DERROTA, SPLASHSCREEN }
var estado_actual: EstadoJuego = EstadoJuego.MENU
var nivel_actual: Node = null

var celdas_cesped: Array[Vector2i] = []
var celda_ocupada: Array[Vector2i] = []

var vida_por_ronda = 100
var puntos_por_ronda = 10

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
			AudioManager.play_menu_music()
		EstadoJuego.MENU:
			get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/menu.tscn")
			vida_por_ronda = 100
			nivel_actual = null
			AudioManager.play_menu_music()
		 
		EstadoJuego.PREPARACION:
			if nivel_actual == null or not is_instance_valid(nivel_actual):
				get_tree().call_deferred("change_scene_to_file", "res://scenes/niveles.tscn")
		
		EstadoJuego.VICTORIA:
			_mostrar_pantalla_final()
			AudioManager.stop_music_with_fade()
		
		EstadoJuego.DERROTA:
			_mostrar_pantalla_final()
			AudioManager.stop_music_with_fade()

func sum_vida_por_ronda():
	vida_por_ronda += 50
	puntos_por_ronda += 5
	
	pass
	
func _on_victoria():
	print("¡Victoria! Todas las hormigas eliminadas")
	cambiar_estado(EstadoJuego.VICTORIA)

func _on_derrota():
	print("¡Derrota! La reina ha muerto")
	cambiar_estado(EstadoJuego.DERROTA)

func _mostrar_pantalla_final():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/menu/pantalla_final.tscn")

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
