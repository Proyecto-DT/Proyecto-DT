extends Node3D

@export var camino_tile:PackedScene

@export var mapa_latitud:int = 16
@export var mapa_longitud:int = 9
 
var _generadorcaminos:GeneradorCaminos

func _ready():
	_generadorcaminos = GeneradorCaminos.new(mapa_latitud, mapa_longitud)
	_mostrar_camino()

func _mostrar_camino():
	var _camino:Array[Vector2i] = _generadorcaminos.genenerar_camino()
	print(_camino)
	for elemento in _camino:	
		var tile:Node3D = camino_tile.instantiate()
		add_child(tile)
		tile.global_position = Vector3(elemento.x, 0, elemento.y)
		
