extends CharacterBody3D

@export var speed: float = 3.0
@export var path: Path3D = null

var path_follow: PathFollow3D
var current_offset: float = 0.0
var is_moving: bool = false
var total_length: float = 0.0
var vida: float = 100

func set_path(nuevo_path: Path3D):
	
	if nuevo_path == null:
		print("ERROR: El path recibido es null")
		return
	
	path = nuevo_path
	
	if not path.curve:
		print("ERROR: El Path3D no tiene una curva asignada")
		return
	
	total_length = path.curve.get_baked_length()
	if total_length == 0:
		print("ERROR: La curva no tiene puntos o tiene longitud 0")
		return
	
	# Crear el PathFollow3D y agregarlo al Path
	path_follow = PathFollow3D.new()
	path.add_child(path_follow)
	
	# Configurar el PathFollow
	path_follow.loop = false
	path_follow.progress = 0
	
	# Iniciar movimiento
	is_moving = true
	

func _physics_process(delta):
	if not is_moving:
		return
	
	if path_follow == null:
		is_moving = false
		return
	
	# Avanzar por la ruta
	current_offset += speed * delta
	
	# Limitar el progreso a la longitud total
	if current_offset >= total_length:
		llegar_al_final()
		return
	
	# Actualizar posición en la ruta
	path_follow.progress = current_offset
	
	# Actualizar posición y rotación del enemigo
	global_position = path_follow.global_position
	global_rotation = path_follow.global_rotation

func llegar_al_final():
	is_moving = false
	
	# Limpiar el PathFollow para evitar errores
	if path_follow:
		path_follow.queue_free()
	
	# Eliminar el enemigo
	queue_free()

# Método opcional para pausar el movimiento
func pausar_movimiento():
	is_moving = false
	print("Movimiento pausado")

# Método opcional para reanudar el movimiento
func reanudar_movimiento():
	if path_follow:
		is_moving = true
		print("Movimiento reanudado")

# Devuelve la ruta
func get_path_follow():
	return path_follow

func _on_area_3d_area_entered(area: Area3D):
	#print("Hormiga detectó: ", area.name)
	#print("Grupos del área: ", area.get_groups())
	
	if area.is_in_group("Proyectiles"):
		vida = vida - area.damage
		$SubViewport/ProgressBar.value = vida
		#print(vida)
		if vida <= 0:
			queue_free()
		area.queue_free()
