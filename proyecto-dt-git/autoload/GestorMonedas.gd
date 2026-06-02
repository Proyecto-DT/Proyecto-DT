extends Node

signal monedas_actualizadas(nuevas_monedas)

var monedas_totales = 0

func sumar_monedas(cantidad):
	monedas_totales += cantidad
	monedas_actualizadas.emit(monedas_totales)

func reset_monedas():
	monedas_totales = 100
