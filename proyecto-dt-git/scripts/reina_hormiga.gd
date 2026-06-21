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
