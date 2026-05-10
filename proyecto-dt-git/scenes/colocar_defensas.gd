extends Button

@export var torreta_gomera: PackedScene
@export var colocar_hormiga_gomera_icono: Texture2D

var colocando: bool = false
var preview: Node3D = null 

func _ready() -> void:
	icon = colocar_hormiga_gomera_icono
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	colocando = true
	if preview == null:
		preview = torreta_gomera.instantiate()
		get_tree().current_scene.add_child(preview)
		preview.set_meta("es_preview", true)

func _process(_delta: float) -> void:
	if not colocando or preview == null:
		return

	var camara = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	var origen = camara.project_ray_origin(mouse_pos)
	var direccion = camara.project_ray_normal(mouse_pos)

	var plano = Plane(Vector3.UP, 0)
	var punto = plano.intersects_ray(origen, direccion)

	if punto:
		preview.global_position = punto

func _input(event: InputEvent) -> void:
	if not colocando:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_colocar_defensa()

func _colocar_defensa() -> void:
	if preview == null:
		return

	var torreta = torreta_gomera.instantiate()
	get_tree().current_scene.add_child(torreta)
	torreta.global_position = preview.global_position

	_cancelar()

func _cancelar() -> void:
	colocando = false
	if preview:
		preview.queue_free()
		preview = null
