extends Node3D

@onready var hormiga_lanza = $Hormiga
var desplazamiento_actual = 0.0
var enemigo_en_rango:Array[Node3D]
var enemigo_actual:Node3D = null
var obtener_progreso:float = 0
@export var dano_lanza = 10

func _process(delta):
	enemigo_actual = obtener_enemigo_mas_avanzado()
	if enemigo_actual == null:
		return
	elif enemigo_actual != null:
		rotacion_hacia_objetivo(enemigo_actual, delta)

func _on_area_3d_area_entered(area: Area3D) -> void:
	if enemigo_actual == null:
		enemigo_actual = area
	enemigo_en_rango.append(area.get_parent())

func _on_area_3d_area_exited(area: Area3D) -> void:
	enemigo_en_rango.erase(area.get_parent())
	
	if enemigo_actual == area:
		enemigo_actual = enemigo_en_rango[0] if enemigo_en_rango.size() > 0 else null

func rotacion_hacia_objetivo(objetivo, delta):
	var dir_hormiga = hormiga_lanza.global_position.direction_to(Vector3(objetivo.global_position.x, global_position.y, objetivo.global_position.z))
	var target_hormiga = hormiga_lanza.basis.looking_at(dir_hormiga)
	var velocidad_rotacion = 5.0
	hormiga_lanza.basis = hormiga_lanza.basis.slerp(target_hormiga, delta * velocidad_rotacion)

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

func _ataque_de_lanza():
	if enemigo_actual == null:
		return
	if !is_instance_valid(enemigo_actual):
		return
	enemigo_actual.vida -= dano_lanza
	if enemigo_actual.has_node("SubViewport/ProgressBar"):
		enemigo_actual.get_node("SubViewport/ProgressBar").value = enemigo_actual.vida
	if enemigo_actual.vida <= 0:
		enemigo_actual.morir()

func _on_timer_golpe_timeout() -> void:
	_ataque_de_lanza()
