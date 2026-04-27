extends Node3D

@export var tile_inicio:PackedScene
@export var tile_final:PackedScene
@export var tile_straight:PackedScene
@export var tile_esquina:PackedScene
@export var tile_cesped:PackedScene

@export var mapa_latitud:int = 16
@export var mapa_longitud:int = 9
 
var _generadorcaminos:GeneradorCaminos

func _ready():
	_generadorcaminos = GeneradorCaminos.new(mapa_latitud, mapa_longitud)
	_mostrar_camino()

func _mostrar_camino():
	var _camino:Array[Vector2i] = _generadorcaminos.generar_camino()
	while _camino.size() < 35:
		_camino = _generadorcaminos.generar_camino()

	print(_camino)
	for elemento in _camino:
		var tile_score:int = _generadorcaminos.get_tile_score(elemento)

		var tile: Node3D = tile_cesped.instantiate()
		var tile_rotation: Vector3 = Vector3.ZERO

		if tile_score == 2:
			tile = tile_inicio.instantiate()
			tile_rotation = Vector3(0,90,0)
		if tile_score == 8:
			tile = tile_final.instantiate()
			tile_rotation = Vector3(0,90,0)
		if tile_score == 10:
			tile = tile_straight.instantiate()
			tile_rotation = Vector3(0,90,0)
		elif tile_score == 1 or tile_score == 4 or tile_score == 5:
			tile = tile_straight.instantiate()
			tile_rotation = Vector3(0,0,0)
		elif tile_score == 6:
			tile = tile_esquina.instantiate()
			tile_rotation = Vector3(0,0,0)
		elif tile_score == 12:
			tile = tile_esquina.instantiate()
			tile_rotation = Vector3(0,270,0)
		elif tile_score == 9:
			tile = tile_esquina.instantiate()
			tile_rotation = Vector3(0,180,0)
		elif tile_score == 3:
			tile = tile_esquina.instantiate()
			tile_rotation = Vector3(0,90,0)
		print (tile_score)

		add_child(tile)
		tile.global_position = Vector3(elemento.x, 0, elemento.y)
		tile.global_rotation_degrees = tile_rotation
		
