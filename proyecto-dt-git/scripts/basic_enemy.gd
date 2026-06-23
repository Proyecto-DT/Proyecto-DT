extends CharacterBody3D

@export var velocidad: float = 1.5
@export var ruta: Path3D = null
@export var escena_explosion: PackedScene

@onready var animation_player = $AnimationPlayer

var ruta_seguimiento: PathFollow3D
var desplazamiento_actual: float = 0.0
var se_mueve: bool = false
var longitud_total: float = 0.0
var vida: float = 100
var valor_puntos = 10
var valor_monedas = 5

signal murio(puntos, monedas)

func _ready():
	add_to_group("enemigos")
	if animation_player:
		animation_player.play("ArmatureAction")

func set_ruta(nueva_ruta: Path3D):
	print("🔍 set_ruta() llamado")
	ruta = nueva_ruta
	longitud_total = ruta.curve.get_baked_length()
	ruta_seguimiento = PathFollow3D.new()
	ruta.add_child(ruta_seguimiento)
	ruta_seguimiento.loop = false
	ruta_seguimiento.progress = 0
	se_mueve = true
	
	if animation_player:
		if animation_player.has_animation("ArmatureAction"):
			animation_player.play("ArmatureAction")
		else:
			var anims = animation_player.get_animation_list()
			if anims.size() > 0:
				animation_player.play(anims[0])

func _physics_process(delta):
	if se_mueve and animation_player and not animation_player.is_playing():
		animation_player.play("ArmatureAction")
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
	_crear_explosion(global_position)
	_danar_reina()
	morir(false)

func _danar_reina():
	var reina = _buscar_reina()
	if reina and reina.has_method("recibir_danio"):
		reina.recibir_danio(10)

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
			morir(true)
		area.queue_free()

func morir(muere_por_torreta):
	if animation_player and animation_player.is_playing():
		animation_player.stop()
	
	if muere_por_torreta:
		murio.emit(valor_puntos, valor_monedas)
	else:
		murio.emit(0, 0)
	call_deferred("queue_free")
	
func _crear_explosion(posicion: Vector3):
	if escena_explosion == null:
		return
	var explosion = escena_explosion.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = posicion + Vector3(-0.7, 0.5, 0)
	explosion.restart()
	explosion.emitting = true
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(explosion):
		explosion.queue_free()

func pausar_movimiento():
	se_mueve = false
	if animation_player:
		animation_player.pause()

func reanudar_movimiento():
	if ruta_seguimiento:
		se_mueve = true
		if animation_player:
			animation_player.play()

func get_ruta_seguimiento():
	return ruta_seguimiento
