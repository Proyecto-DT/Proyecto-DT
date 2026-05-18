extends Control

@onready var panel_menu: VBoxContainer = $PanelMenu
@onready var opciones: VBoxContainer = $Opciones

func _ready():
	panel_menu.visible = true
	opciones.visible = false

func _on_nueva_partida_pressed() -> void:
	GameManager.cambiar_estado(GameManager.EstadoJuego.PREPARACION)

func _on_opciones_pressed() -> void:
	panel_menu.visible = false
	opciones.visible = true

func _on_salir_pressed() -> void:
	get_tree().quit()

func _on_volver_pressed() -> void:
	panel_menu.visible = true 
	opciones.visible = false
