extends CharacterBody3D

@export var velocidad: float = 1.5
@export var ruta: Path3D = null

var ruta_seguimiento: PathFollow3D
var desplazamiento_actual: float = 0.0
var se_mueve: bool = false
var longitud_total: float = 0.0
var vida: float = 100

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
	
	# Configuraciones de PathFollow
	ruta_seguimiento.loop = false
	ruta_seguimiento.progress = 0
	
	# Iniciar movimiento
	se_mueve = true
	

func _physics_process(delta):
	if not se_mueve:
		return
	
	if ruta_seguimiento == null:
		se_mueve = false
		return
	
	desplazamiento_actual += velocidad * delta
	
	# Limitar el progreso a la longitud total
	if desplazamiento_actual >= longitud_total:
		llegar_al_final()
		return
	
	# Actualizar posicion en la ruta
	ruta_seguimiento.progress = desplazamiento_actual
	
	# Actualizar posicion y rotacion del enemigo
	global_position = ruta_seguimiento.global_position
	global_rotation = ruta_seguimiento.global_rotation

func llegar_al_final():
	se_mueve = false
	
	if ruta_seguimiento:
		ruta_seguimiento.queue_free()
	
	# Eliminar el enemigo
	queue_free()

# Metodo opcional para pausar el movimiento
func pausar_movimiento():
	se_mueve = false
	print("Movimiento pausado")

# Método opcional para reanudar el movimiento
func reanudar_movimiento():
	if ruta_seguimiento:
		se_mueve = true
		print("Movimiento reanudado")

func get_ruta_seguimiento():
	return ruta_seguimiento

func _on_area_3d_area_entered(area: Area3D):
	#print("Hormiga detectó: ", area.name)
	#print("Grupos del área: ", area.get_groups())
	
	if area.is_in_group("Proyectiles"):
		vida = vida - area.dano
		$SubViewport/ProgressBar.value = vida
		#print(vida)
		if vida <= 0:
			queue_free()
		area.queue_free()
