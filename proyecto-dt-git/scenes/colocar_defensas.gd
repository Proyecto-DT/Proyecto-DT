extends Button

@export var torreta_gomera: PackedScene
@export var colocar_defensas_icono: Texture2D

var colocando: bool = false
var vista_previa: Node3D = null 

func _ready() -> void:
	icon = colocar_defensas_icono

func _on_pressed() -> void:
	colocando = true
	if vista_previa == null:
		vista_previa = torreta_gomera.instantiate()
		get_tree().current_scene.add_child(vista_previa)
		vista_previa.set_meta("es_vista_previa", true)

func _process(_delta: float) -> void:
	if not colocando or vista_previa == null:
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

	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT and evento.pressed:
		_colocar_defensa()

func _colocar_defensa() -> void:
	if vista_previa == null:
		return
	var torreta = torreta_gomera.instantiate()
	get_tree().current_scene.add_child(torreta)
	torreta.global_position = vista_previa.global_position
	_cancelar()

func _cancelar() -> void:
	colocando = false
	if vista_previa:
		vista_previa.queue_free()
		vista_previa = null
