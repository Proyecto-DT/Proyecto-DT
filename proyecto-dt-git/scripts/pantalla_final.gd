extends Control

@onready var titulo_victoria: Label = $TituloVictoria
@onready var titulo_derrota: Label = $TituloDerrota
@onready var puntaje_label: Label = $Puntaje
@onready var boton_continuar: Button = $BotonContinuar
@onready var boton_menu: Button = $BotonMenu

func _ready():
	var es_victoria = (GameManager.estado_actual == GameManager.EstadoJuego.VICTORIA)
	
	titulo_victoria.visible = es_victoria
	titulo_derrota.visible = not es_victoria
	boton_continuar.visible = es_victoria
	
	if es_victoria:
		GestorPuntaje.sumar_puntos(100)
	
	puntaje_label.text = "Puntaje: " + str(GestorPuntaje.puntaje_total)
	
	boton_menu.pressed.connect(_on_boton_menu_pressed)
	boton_continuar.pressed.connect(_on_boton_continuar_pressed)

func _on_boton_menu_pressed():
	print("Botón Menú presionado - Volviendo al MENU")
	GameManager.cambiar_estado(GameManager.EstadoJuego.MENU)

func _on_boton_continuar_pressed():
	print("Botón Continuar presionado - Nueva oleada")
	GameManager.puntaje_actual += 100
	GameManager.cambiar_estado(GameManager.EstadoJuego.PREPARACION)
