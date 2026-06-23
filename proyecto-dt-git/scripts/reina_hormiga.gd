extends StaticBody3D
class_name ReinaHormiga

signal reina_muerta

@export var vida_maxima: int = 50
var vida_actual: int

func _ready():
	add_to_group("reina")
	vida_actual = vida_maxima
	_actualizar_barra_vida()

func recibir_danio(cantidad: int):
	vida_actual -= cantidad
	_actualizar_barra_vida()
	_shake_camera()
	if vida_actual <= 0:
		morir()

func _actualizar_barra_vida():
	print("Vida de la reina: ", vida_actual, "/", vida_maxima)
	# barra de vida por UI
	# $BarraVida.value = vida_actual

func morir():
	print("¡La reina ha muerto!")
	reina_muerta.emit()
	queue_free()

func revivir():
	vida_actual = vida_maxima
	_actualizar_barra_vida()
	print("Reina revivida")

func _shake_camera(duration: float = 0.3, intensity: float = 0.1):
	var nivel = get_tree().current_scene
	var camera = nivel.get_node_or_null("Camera3D")
	if not camera:
		return
	
	var original = camera.global_position
	var tween = create_tween()
	tween.set_parallel(false)
	
	for i in range(10):
		var offset = Vector3(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity) * 0.3
		)
		tween.tween_property(camera, "global_position", original + offset, duration / 20.0)
		tween.tween_property(camera, "global_position", original, duration / 20.0)
	
	tween.tween_callback(func(): camera.global_position = original)
	
	
