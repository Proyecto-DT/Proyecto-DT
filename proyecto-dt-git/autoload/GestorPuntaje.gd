extends Node

signal puntaje_actualizado(nuevo_puntaje)

var puntaje_total = 0

func sumar_puntos(cantidad):
	puntaje_total += cantidad
	puntaje_actualizado.emit(puntaje_total)

func reset_puntaje():
	puntaje_total = 0
