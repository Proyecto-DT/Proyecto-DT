extends Node3D

var enemigo_en_rango:Array[Node3D]
var enemigo_actual:Node3D = null
var objetivo_enemigo_actual:bool = false
var obtener_progreso:float = 0

func _process(delta):
	if objetivo_enemigo_actual:
		$Hormiga.look_at(enemigo_actual.global_position)
		$Torreta.look_at(enemigo_actual.global_position)
	elif enemigo_actual != null:
		rotacion_hacia_objetivo(enemigo_actual, delta)

func _on_rango_area_entered(area: Area3D):
	print(area, " entro")
	if enemigo_actual == null:
		enemigo_actual = area
	enemigo_en_rango.append(area)
	print(enemigo_en_rango.size())

func _on_rango_area_exited(area: Area3D):
	print(area, " salio")
	enemigo_en_rango.erase(area)
	print(enemigo_en_rango.size())
	
func rotacion_hacia_objetivo(objetivo, delta):
	var vector_objetivo = $Hormiga.global_position.direction_to(Vector3(objetivo.global_position.x, global_position.y, objetivo.global_position.z))
	var vector_objetivo_1 = $Torreta.global_position.direction_to(Vector3(objetivo.global_position.x, global_position.y, objetivo.global_position.z))
	var objetivo_base = $Hormiga.basis.looking_at(vector_objetivo)
	var objetivo_base_1 = $Torreta.basis.looking_at(vector_objetivo_1)
	$Hormiga.basis = $Hormiga.basis.slerp(objetivo_base, obtener_progreso)
	$Torreta.basis = $Torreta.basis.slerp(objetivo_base_1, obtener_progreso)
	obtener_progreso += delta * 0.2
	
	if obtener_progreso > 1:
		objetivo_enemigo_actual = true
