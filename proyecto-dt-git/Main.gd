extends Node3D

var menu_ui = null
var nivel = null

func _ready():
	GameManager.estado_cambiado.connect(_on_estado_cambiado)
	
	nivel = preload("res://node_3d.tscn").instantiate()
	add_child(nivel)
	nivel.visible = false

func _on_estado_cambiado(nuevo_estado: String):
	match nuevo_estado:
		"Menu":
			mostrar_menu()
			if nivel:
				nivel.visible = false
		"Preparacion":
			ocultar_menu()
			if nivel:
				nivel.visible = true
				var spawner = nivel.get_node("Spawner")
				if spawner:
					spawner.enemigos_generados = 0
					spawner.estado_generador = true
					spawner.siguiente_generacion_enemigo()
		"Invasion":
			pass
		"GameOver":
			pass

func mostrar_menu():
	if menu_ui == null:
		menu_ui = load("res://scenes/menu/menu.tscn").instantiate()
		add_child(menu_ui)
		var boton = menu_ui.get_node("PanelMenu/NuevaPartida")
		if boton:
			boton.pressed.connect(_on_nueva_partida)

func ocultar_menu():
	if menu_ui:
		menu_ui.queue_free()
		menu_ui = null

func _on_nueva_partida():
	ocultar_menu()
	GameManager.iniciar_nueva_partida()
