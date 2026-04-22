extends Object
class_name GeneradorCaminos

var _cuadricula_longitud:int = 16
var _cuadricula_latitud:int = 9

var _camino: Array[Vector2i]

func _init(longitud:int,latitud:int):
	_cuadricula_latitud = latitud
	_cuadricula_longitud = longitud

func genenerar_camino():
	_camino.clear()
	
	var x = 0
	var y = int(_cuadricula_latitud/2)
	
	while x < _cuadricula_longitud:
		if not _camino.has(Vector2i(x,y)):
			_camino.append(Vector2i(x,y))
		
		var choice:int = randi_range(0,2)
		

		if choice == 0 or x % 2 == 0 or x == _cuadricula_longitud-1:
			x += 1
		elif choice == 1 and y < _cuadricula_latitud and not _camino.has(Vector2i(x, y+1)):
			y += 1
		elif choice == 2 and y > 0 and not _camino.has(Vector2i(x, y-1)):
			y -= 1
		
	return _camino
