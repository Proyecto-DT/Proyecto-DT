extends Button

@export var hormiga_lanza: PackedScene
@export var colocar_defensas_icon: Texture2D

var colocando: bool = false
var vista_previa: Node3D = null 

func _ready() -> void:
	icon = colocar_defensas_icon
	# señal de cambio de estado
	GameManager.estado_cambiado.connect(_on_estado_cambiado)
	# actualizar visibilidad inicial
	_on_estado_cambiado(GameManager.estado_actual)

func _on_estado_cambiado(nuevo_estado):
	# solo visible en estado PREPARACION
	visible = (nuevo_estado == GameManager.EstadoJuego.PREPARACION)
	
	if nuevo_estado != GameManager.EstadoJuego.PREPARACION and colocando:
		_cancelar()

func _on_pressed() -> void:
	if GameManager.estado_actual != GameManager.EstadoJuego.PREPARACION:
		return
	
	colocando = true
	if vista_previa == null:
		vista_previa = hormiga_lanza.instantiate()
		get_tree().current_scene.add_child(vista_previa)
		vista_previa.set_meta("es_vista_previa", true)
		
func _process(_delta: float) -> void:
	if not colocando or vista_previa == null:
		return
	
	if GameManager.estado_actual != GameManager.EstadoJuego.PREPARACION:
		_cancelar()
		return
	
	var camara = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	var origen = camara.project_ray_origin(mouse_pos)
	var direccion = camara.project_ray_normal(mouse_pos)
	var plano = Plane(Vector3.UP, 0)
	var punto = plano.intersects_ray(origen, direccion)

	if punto:
		vista_previa.global_position = punto

func _input(evento: InputEvent) -> void:
	if not colocando:
		return
	
	if GameManager.estado_actual != GameManager.EstadoJuego.PREPARACION:
		return

	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT and evento.pressed:
		_colocar_defensa()
	
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_RIGHT and evento.pressed:
		_cancelar()

func _colocar_defensa() -> void:
	if vista_previa == null:
		return
	var lanza = hormiga_lanza.instantiate()
	get_tree().current_scene.add_child(lanza)
	lanza.global_position = vista_previa.global_position
	_cancelar()
	
func _cancelar() -> void:
	colocando = false
	if vista_previa:
		vista_previa.queue_free()
		vista_previa = null
