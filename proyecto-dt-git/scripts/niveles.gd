extends Node3D

@export var tile_inicio:PackedScene
@export var tile_final:PackedScene
@export var tile_straight:PackedScene
@export var tile_esquina:PackedScene
@export var tile_cruce:PackedScene
@export var tile_cesped_bloqueado:Array[PackedScene]
@export var tile_cesped:PackedScene
@export var tile_enemigo:PackedScene
@export var escena_reina:PackedScene

@onready var spawner_node = $Spawner

var label_preparacion: Label = null

@export var mapa_longitud:int = 16
@export var mapa_latitud:int = 10

@export var min_path_size = 50
@export var max_path_size = 70
@export var min_loops = 3
@export var max_loops = 5
 
var _generadorcaminos:GeneradorCaminos
var path_3d:Path3D 

func _ready(): 
	_generadorcaminos = GeneradorCaminos.new(mapa_latitud, mapa_longitud)
	_mostrar_camino()
	_completar_mapa()
	
	spawner_node.estado_generador = false
	spawner_node.enemigos_generados = 0
	spawner_node.enemigos_vivos = 0
	
	if not spawner_node.todas_hormigas_muertas.is_connected(_on_victoria):
		spawner_node.todas_hormigas_muertas.connect(_on_victoria)
	
	var reina = _buscar_reina(self)
	if reina and not reina.reina_muerta.is_connected(_on_derrota):
		reina.reina_muerta.connect(_on_derrota)
	
	_crear_label_preparacion()
	
	if GameManager.estado_actual == GameManager.EstadoJuego.PREPARACION:
		_mostrar_label_preparacion()
	
	spawner_node.configurar_ruta(path_3d)
	await get_tree().process_frame
	AudioManager.play_game_music()
	
func _crear_label_preparacion():
	if label_preparacion == null:
		label_preparacion = Label.new()
		label_preparacion.text = "Presiona Enter para terminar preparación"
		label_preparacion.add_theme_color_override("font_color", Color.WHITE)
		label_preparacion.add_theme_font_size_override("font_size", 20)
		label_preparacion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label_preparacion.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label_preparacion.modulate.a = 1.0
		
		var canvas = CanvasLayer.new()
		add_child(canvas)
		canvas.add_child(label_preparacion)
		
		label_preparacion.position = Vector2(0, get_viewport().size.y - 250)
		label_preparacion.size = Vector2(get_viewport().size.x, 40)		
		label_preparacion.visible = false

func _mostrar_label_preparacion():
	if label_preparacion:
		label_preparacion.visible = true
		if label_preparacion.get_child_count() > 0:
			var old_tween = label_preparacion.get_child(0)
			if old_tween is Tween:
				old_tween.kill()
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(label_preparacion, "modulate:a", 0.1, 0.5)
		tween.tween_property(label_preparacion, "modulate:a", 1.0, 0.5)

func _ocultar_label_preparacion():
	if label_preparacion:
		label_preparacion.visible = false
		if label_preparacion.get_child_count() > 0:
			var tween = label_preparacion.get_child(0)
			if tween is Tween:
				tween.kill()
		label_preparacion.modulate.a = 1.0

func _input(event):
	if GameManager.estado_actual == GameManager.EstadoJuego.PREPARACION:
		if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
			_iniciar_invasion()

func _iniciar_invasion():
	print("Iniciando invasión desde niveles.gd")
	
	_ocultar_label_preparacion()
	
	GameManager.cambiar_estado(GameManager.EstadoJuego.INVASION)
	
	spawner_node.inicio_generacion()

func _completar_mapa():
	var celdas_libres: Array[Vector2i] = []
	for x in range(mapa_longitud):
		for y in range(mapa_latitud):
			if not _generadorcaminos.obtener_camino().has(Vector2i(x,y)):
				var tile: Node3D
				
				if tile_cesped_bloqueado.size() > 0 and randf() < 0.2:
					tile = tile_cesped_bloqueado.pick_random().instantiate()
				else:
					tile = tile_cesped.instantiate()
					celdas_libres.append(Vector2i(x, y))
				
				add_child(tile)
				tile.position = Vector3(x, 0, y)
				tile.rotation_degrees = Vector3(0, randi_range(0,3)*90, 0)
				
	GameManager.registrar_cesped(celdas_libres)

func _mostrar_camino(): 
	var _iteration_count:int = 1
	_generadorcaminos.generar_camino(true)
	
	while (_generadorcaminos.obtener_camino().size() < min_path_size or _generadorcaminos.obtener_camino().size() > max_path_size or _generadorcaminos.get_loop_count() < min_loops or _generadorcaminos.get_loop_count() > max_loops):
		_iteration_count += 1
		_generadorcaminos.generar_camino(true)
	
	path_3d = Path3D.new()
	add_child(path_3d)
	
	var c3d:Curve3D = Curve3D.new()
	for elemento in _generadorcaminos.obtener_camino():
		c3d.add_point(Vector3(elemento.x, 0.1, elemento.y))
	
	path_3d.curve = c3d

	for i in range(_generadorcaminos.obtener_camino().size()):
		var tile_score:int = _generadorcaminos.get_tile_score(i)
		var tile:Node3D = tile_cesped.instantiate()
		var tile_rotation: Vector3 = Vector3.ZERO

		if tile_score == 5:
			tile = tile_straight.instantiate()
			tile_rotation = Vector3(0,90,0)
		elif tile_score == 10:
			tile = tile_straight.instantiate()
			tile_rotation = Vector3(0,0,0)
		elif tile_score == 6:
			tile = tile_esquina.instantiate()
			tile_rotation = Vector3(0,0,0)
		elif tile_score == 12:
			tile = tile_esquina.instantiate()
			tile_rotation = Vector3(0,90,0)
		elif tile_score == 9:
			tile = tile_esquina.instantiate()
			tile_rotation = Vector3(0,180,0)
		elif tile_score == 3:
			tile = tile_esquina.instantiate()
			tile_rotation = Vector3(0,270,0)
		elif tile_score == 7 or tile_score == 11 or tile_score == 13 or tile_score == 14 or tile_score == 15:
			tile = tile_cruce.instantiate()
			tile_rotation = Vector3(0, 0, 0)
		elif tile_score == 1:
			tile = tile_final.instantiate()
			tile_rotation = Vector3(0, -90, 0)
			var pos = _generadorcaminos.get_path_tile(i)
			var reina = escena_reina.instantiate()
			add_child(reina)
			reina.position = Vector3(pos.x, 0.5, pos.y)
		elif tile_score == 4:
			tile = tile_inicio.instantiate()
			tile_rotation = Vector3(0, 90, 0)
		else:
			tile = tile_cesped.instantiate()

		add_child(tile)
		tile.position = Vector3(_generadorcaminos.get_path_tile(i).x, 0, _generadorcaminos.get_path_tile(i).y)
		tile.rotation_degrees = tile_rotation

func _buscar_reina(nodo: Node) -> Node:
	if not nodo:
		return null
	for hijo in nodo.get_children():
		if hijo.is_in_group("reina"):
			return hijo
		var encontrado = _buscar_reina(hijo)
		if encontrado:
			return encontrado
	return null

func _on_victoria():
	print("Victoria desde niveles.gd")
	GameManager.cambiar_estado(GameManager.EstadoJuego.VICTORIA)

func _on_derrota():
	print("Derrota desde niveles.gd")
	GameManager.cambiar_estado(GameManager.EstadoJuego.DERROTA)
