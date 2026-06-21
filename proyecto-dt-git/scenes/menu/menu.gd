extends Control

@onready var panel_menu: VBoxContainer = $PanelMenu
@onready var opciones: VBoxContainer = $Opciones
@onready var panel_volumen: VBoxContainer = $PanelVolumen
@onready var volumen_slider: HSlider = $PanelVolumen/VolumenSlider
@onready var label_volumen: Label = $PanelVolumen/LabelVolumen
@onready var boton_volver_volumen: Button = $PanelVolumen/BotonVolver
@onready var boton_volumen: Button = $Opciones/Volumen   # <--- nombre correcto

func _ready():
	panel_menu.visible = true
	opciones.visible = false
	panel_volumen.visible = false
	
	_conectar_hover_botones($PanelMenu)
	_conectar_hover_botones($Opciones)
	_conectar_hover_botones($PanelVolumen)
	
	# Conectar señales de los botones
	boton_volumen.pressed.connect(_on_boton_volumen_pressed)
	boton_volver_volumen.pressed.connect(_on_volver_volumen_pressed)
	volumen_slider.value_changed.connect(_on_volumen_slider_value_changed)
	
	# Sincronizar slider con volumen actual
	_actualizar_interfaz_volumen()

# ---- Funciones auxiliares ----
func _conectar_hover_botones(nodo: Node):
	for hijo in nodo.get_children():
		if hijo is Button:
			hijo.mouse_entered.connect(_on_boton_hover)
		if hijo.get_child_count() > 0:
			_conectar_hover_botones(hijo)

func _on_boton_hover():
	AudioManager.ui_hover()

# ---- Navegación principal ----
func _on_nueva_partida_pressed() -> void:
	AudioManager.ui_select()
	GestorPuntaje.reset_puntaje()
	GestorMonedas.reset_monedas()
	GameManager.cambiar_estado(GameManager.EstadoJuego.PREPARACION)

func _on_opciones_pressed() -> void:
	AudioManager.ui_select()
	panel_menu.visible = false
	opciones.visible = true
	panel_volumen.visible = false

func _on_salir_pressed() -> void:
	AudioManager.ui_select()
	get_tree().quit()

func _on_volver_pressed() -> void:
	AudioManager.ui_select()
	panel_menu.visible = true 
	opciones.visible = false
	panel_volumen.visible = false

# ---- Navegación a panel de volumen ----
func _on_boton_volumen_pressed() -> void:
	AudioManager.ui_select()
	opciones.visible = false
	panel_volumen.visible = true
	_centrar_panel_volumen()   # <--- Ajustar posición/tamaño
	_actualizar_interfaz_volumen()

func _on_volver_volumen_pressed() -> void:
	AudioManager.ui_select()
	panel_volumen.visible = false
	opciones.visible = true

# ---- Control de volumen ----
func _actualizar_interfaz_volumen():
	var bus_idx = AudioServer.get_bus_index("Master")
	var volumen_db = AudioServer.get_bus_volume_db(bus_idx)
	var valor_lineal = 100 * (volumen_db + 80) / 80
	valor_lineal = clamp(valor_lineal, 0, 100)
	volumen_slider.set_value_no_signal(valor_lineal)
	label_volumen.text = str(round(valor_lineal)) + "%"

func _on_volumen_slider_value_changed(value: float):
	var volumen_db = -80 + (value / 100) * 80
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_idx, volumen_db)
	label_volumen.text = str(round(value)) + "%"

# ---- Centrar y agrandar el panel de volumen ----
func _centrar_panel_volumen():
	# 1. Panel ocupa casi toda la pantalla (con márgenes del 10%)
	panel_volumen.anchor_left = 0.1
	panel_volumen.anchor_top = 0.1
	panel_volumen.anchor_right = 0.9
	panel_volumen.anchor_bottom = 0.9
	panel_volumen.offset_left = 0
	panel_volumen.offset_top = 0
	panel_volumen.offset_right = 0
	panel_volumen.offset_bottom = 0
	
	# 2. Configurar el VBoxContainer para centrar verticalmente
	panel_volumen.alignment = BoxContainer.ALIGNMENT_CENTER
	panel_volumen.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
	panel_volumen.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_FILL
	
	# 3. Agrandar el label (fuente más grande)
	label_volumen.add_theme_font_size_override("font_size", 50)
	
	# 4. Configurar el slider para que ocupe un ancho razonable y tenga altura
	volumen_slider.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
	volumen_slider.custom_minimum_size = Vector2(400, 40)  # Ancho mínimo, altura mayor
	
	# 5. CONFIGURAR EL BOTÓN VOLVER: centrado y con tamaño adecuado
	boton_volver_volumen.size_flags_horizontal = Control.SIZE_SHRINK_CENTER  # Centrado
	boton_volver_volumen.custom_minimum_size = Vector2(200, 60)  # Tamaño visible
	boton_volver_volumen.add_theme_font_size_override("font_size", 30)  # Texto más grande
	
	# 6. Asegurar que todos los hijos se centren horizontalmente
	for child in panel_volumen.get_children():
		if child is Control and child != label_volumen and child != volumen_slider and child != boton_volver_volumen:
			child.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
