extends Node
class_name State

signal transicion_solicitada(nuevo_estado: String)

func entrar() -> void:
	pass

func salir() -> void:
	pass

func actualizar(_delta: float) -> void:
	pass

func procesar_input(_event: InputEvent) -> void:
	pass
