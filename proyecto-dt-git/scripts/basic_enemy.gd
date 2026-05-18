extends CharacterBody3D

@export var velocidad: float = 1.5
@export var ruta: Path3D = null

var ruta_seguimiento: PathFollow3D
var desplazamiento_actual: float = 0.0
var se_mueve: bool = false
var longitud_total: float = 0.0
var vida: float = 100

signal murio

func _ready():
	add_to_group("enemigos")

func set_ruta(nueva_ruta: Path3D):
	if nueva_ruta == null:
		print("ERROR: La ruta recibida es null")
		return
	
	ruta = nueva_ruta
	
	if not ruta.curve:
		print("ERROR: El Path3D no tiene una curva asignada")
		return
	
	longitud_total = ruta.curve.get_baked_length()
	if longitud_total == 0:
		print("ERROR: La curva no tiene puntos")
		return
	
	ruta_seguimiento = PathFollow3D.new()
	ruta.add_child(ruta_seguimiento)
	
	ruta_seguimiento.loop = false
	ruta_seguimiento.progress = 0
	
	se_mueve = true

func _physics_process(delta):
	if not se_mueve:
		return
	
	if ruta_seguimiento == null:
		se_mueve = false
		return
	
	desplazamiento_actual += velocidad * delta
	
	if desplazamiento_actual >= longitud_total:
		llegar_al_final()
		return
	
	ruta_seguimiento.progress = desplazamiento_actual
	global_position = ruta_seguimiento.global_position
	global_rotation = ruta_seguimiento.global_rotation

func llegar_al_final():
	se_mueve = false
	
	if ruta_seguimiento:
		ruta_seguimiento.queue_free()
	
	# daño a la reina
	_danar_reina()
	
	# morir despues de dañar a la reina
	morir()

func _danar_reina():
	var reina = _buscar_reina()
	if reina and reina.has_method("recibir_danio"):
		reina.recibir_danio(10)
		print("Hormiga dañó a la reina. Vida restante: ", reina.vida_actual)

func _buscar_reina():
	var reinas = get_tree().get_nodes_in_group("reina")
	if reinas.size() > 0:
		return reinas[0]
	return null

func _on_area_3d_area_entered(area: Area3D):
	if area.is_in_group("Proyectiles"):
		vida = vida - area.dano
		$SubViewport/ProgressBar.value = vida
		if vida <= 0:
			morir()
		area.queue_free()

func morir():
	murio.emit()
	queue_free()

func pausar_movimiento():
	se_mueve = false

func reanudar_movimiento():
	if ruta_seguimiento:
		se_mueve = true

func get_ruta_seguimiento():
	return ruta_seguimiento
