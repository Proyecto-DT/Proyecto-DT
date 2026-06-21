extends Node3D

@export var tile_inicio:PackedScene
@export var tile_final:PackedScene
@export var tile_straight:PackedScene
@export var tile_esquina:PackedScene
@export var tile_cruce:PackedScene
@export var tile_cesped_bloqueado:Array[PackedScene]
@export var tile_cesped:PackedScene
@export var tile_enemigo:PackedScene

# Referencia al nodo Spawner (hijo)
@onready var spawner_node = $Spawner

#Tamaño del mapa
@export var mapa_longitud:int = 16
@export var mapa_latitud:int = 10

#Restricciones del camino
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

	GameManager._iniciar_invasion(path_3d)

func _completar_mapa():
	var celdas_libres: Array[Vector2i] = []
	for x in range(mapa_longitud):
		for y in range(mapa_latitud):
			if not _generadorcaminos.obtener_camino().has(Vector2i(x,y)):
				var tile: Node3D
				
				if tile_cesped_bloqueado.size() > 0 and randf() < 0.2: #probabilidad de salir cesped bloqueado
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
		elif tile_score == 4:
			tile = tile_inicio.instantiate()
			tile_rotation = Vector3(0, 90, 0)
		else:
			tile = tile_cesped.instantiate()

		add_child(tile)
		tile.position = Vector3(_generadorcaminos.get_path_tile(i).x, 0, _generadorcaminos.get_path_tile(i).y)
		tile.rotation_degrees = tile_rotation
