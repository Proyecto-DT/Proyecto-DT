extends Node3D
class_name Spawner

signal todas_hormigas_muertas

@export var escena_enemigo: PackedScene
@export var total_enemigos: int = 10
@export var intervalo_generacion: float = 0.5

var ruta_a_seguir: Path3D
var enemigos_generados: int = 0
var enemigos_vivos: int = 0
var estado_generador: bool = false

func _ready():
	pass

func configurar_ruta(ruta: Path3D):
	ruta_a_seguir = ruta

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
		if enemigos_generados >= total_enemigos:
			_verificar_todas_muertas()

func aparicion_enemiga():
	var enemigo = escena_enemigo.instantiate()
	add_child(enemigo)
	if GameManager.vida_por_ronda > 100:
		enemigo.actualizar_nueva_vida(GameManager.vida_por_ronda, GameManager.puntos_por_ronda)
	AudioManager.spawn_enemy()
	
	if enemigo.has_method("set_ruta"):
		enemigo.set_ruta(ruta_a_seguir)
	
	if enemigo.has_signal("murio"):
		if not enemigo.murio.is_connected(_on_enemigo_murio):
			enemigo.murio.connect(_on_enemigo_murio)

func _on_enemigo_murio(puntos, monedas):
	enemigos_vivos -= 1
	print("Enemigo muerto. Vivos restantes: ", enemigos_vivos)
	
	AudioManager.enemy_dead()
	GestorPuntaje.sumar_puntos(puntos)
	GestorMonedas.sumar_monedas(monedas)
	
	_verificar_todas_muertas()

func _verificar_todas_muertas():
	if enemigos_vivos <= 0 and enemigos_generados >= total_enemigos:
		todas_hormigas_muertas.emit()
		print("TODAS las hormigas han muerto")

func detener_generacion():
	estado_generador = false
