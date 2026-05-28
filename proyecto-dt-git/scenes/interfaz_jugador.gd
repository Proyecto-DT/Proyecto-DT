extends Control

@onready var label_puntos = $Puntos
@onready var label_monedas = $Monedas
#@onready var boton_torreta = $ColocarHormigaGomera

func _ready():
	GestorPuntaje.puntaje_actualizado.connect(_actualizar_puntos)
	GestorMonedas.monedas_actualizadas.connect(_actualizar_monedas)
	
	_actualizar_puntos(GestorPuntaje.puntaje_total)
	_actualizar_monedas(GestorMonedas.monedas_totales)

func _actualizar_puntos(nuevo_puntaje):
	if label_puntos:
		label_puntos.text = "Puntos: " + str(nuevo_puntaje)

func _actualizar_monedas(nuevas_monedas):
	if label_monedas:
		label_monedas.text = "Monedas: " + str(nuevas_monedas)
