extends Node3D

@export var escena_proyectil: PackedScene
@onready var hormiga = $Hormiga

var enemigo_en_rango:Array[Node3D]
var enemigo_actual:Node3D = null
var obtener_progreso:float = 0

func _process(delta):
	enemigo_actual = obtener_enemigo_mas_avanzado()
	if enemigo_actual == null:
		return
	elif enemigo_actual != null:
		rotacion_hacia_objetivo(enemigo_actual, delta)

func _on_rango_area_entered(area: Area3D):
	if enemigo_actual == null:
		enemigo_actual = area
	enemigo_en_rango.append(area.get_parent())

func _on_rango_area_exited(area: Area3D):
	enemigo_en_rango.erase(area.get_parent())
	
	if enemigo_actual == area:
		enemigo_actual = enemigo_en_rango[0] if enemigo_en_rango.size() > 0 else null

func rotacion_hacia_objetivo(objetivo, delta):
	var dir_hormiga = hormiga.global_position.direction_to(Vector3(objetivo.global_position.x, global_position.y, objetivo.global_position.z))
	var target_hormiga = hormiga.basis.looking_at(dir_hormiga)
	var velocidad_rotacion = 5.0
	hormiga.basis = hormiga.basis.slerp(target_hormiga, delta * velocidad_rotacion)

func obtener_enemigo_mas_avanzado():
	var primero = null
	var mayor_progreso = -1.0
	
	for enemigo in enemigo_en_rango:
		if enemigo == null:
			continue
		if enemigo.desplazamiento_actual > mayor_progreso:
			mayor_progreso = enemigo.desplazamiento_actual
			primero = enemigo
	return primero

func atacar_objetivo():
	if enemigo_actual == null:
		return
	
	var proyectil = escena_proyectil.instantiate()
	get_tree().current_scene.add_child(proyectil)
	
	proyectil.global_position = hormiga.global_position
	
	var dir = (enemigo_actual.global_position - proyectil.global_position).normalized()
	proyectil.direccion = dir

func _on_timer_disparo_timeout() -> void:
	atacar_objetivo()
