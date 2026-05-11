extends Node3D

@export var escena_enemigo: PackedScene
@export var ruta_a_seguir: Path3D
@export var total_enemigos: int = 10
@export var intervalo_generacion: float = 0.5

var enemigos_generados: int = 0
var estado_generador: bool = false

func _ready():
	inicio_generacion()

func inicio_generacion():
	estado_generador = true
	siguiente_generacion_enemigo()

func siguiente_generacion_enemigo():
	if enemigos_generados < total_enemigos and estado_generador:
		aparicion_enemiga()
		enemigos_generados += 1
		
		# Programar el siguiente spawn
		await get_tree().create_timer(intervalo_generacion).timeout
		siguiente_generacion_enemigo()

func aparicion_enemiga():
	if not escena_enemigo or not ruta_a_seguir:
		print("Error: Faltan asignar la escena del enemigo o la ruta")
		return
	
	var enemigo = escena_enemigo.instantiate()
	add_child(enemigo)
	
	# Configurar el enemigo
	if enemigo.has_method("set_ruta"):
		enemigo.set_ruta(ruta_a_seguir)
