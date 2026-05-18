extends Node3D
class_name Spawner

signal oleada_completada
signal todas_hormigas_muertas

@export var escena_enemigo: PackedScene
@export var ruta_a_seguir: Path3D
@export var total_enemigos: int = 10
@export var intervalo_generacion: float = 0.5

var enemigos_generados: int = 0
var enemigos_vivos: int = 0
var estado_generador: bool = false

func _ready():
	pass

func inicio_generacion():
	estado_generador = true
	enemigos_generados = 0
	enemigos_vivos = 0
	siguiente_generacion_enemigo()

func siguiente_generacion_enemigo():
	if enemigos_generados < total_enemigos and estado_generador:
		aparicion_enemiga()
		enemigos_generados += 1
		enemigos_vivos += 1
		
		await get_tree().create_timer(intervalo_generacion).timeout
		siguiente_generacion_enemigo()
	else:
		pass

func aparicion_enemiga():
	if not escena_enemigo or not ruta_a_seguir:
		print("Error: Faltan asignar la escena del enemigo o la ruta")
		return
	
	var enemigo = escena_enemigo.instantiate()
	add_child(enemigo)
	
	if enemigo.has_method("set_ruta"):
		enemigo.set_ruta(ruta_a_seguir)
	
	# conectar señal de muerte
	if enemigo.has_signal("murio"):
		if not enemigo.murio.is_connected(_on_enemigo_murio):
			enemigo.murio.connect(_on_enemigo_murio)

func _on_enemigo_murio():
	enemigos_vivos -= 1
	print("Enemigo muerto. Vivos restantes: ", enemigos_vivos)
	_verificar_todas_muertas()

func _verificar_todas_muertas():
	if enemigos_vivos <= 0 and enemigos_generados >= total_enemigos:
		todas_hormigas_muertas.emit()
		print("TODAS las hormigas han muerto")

func detener_generacion():
	estado_generador = false
