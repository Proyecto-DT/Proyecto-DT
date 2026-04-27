extends Object
class_name GeneradorCaminos

var _cuadricula_longitud:int = 16
var _cuadricula_latitud:int = 9

var _camino: Array[Vector2i]

func _init(longitud:int,latitud:int):
	_cuadricula_latitud = latitud
	_cuadricula_longitud = longitud

func generar_camino(): 
	_camino.clear() #Borra el camino anterior, si existia alguno.
	
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

func get_tile_score(tile: Vector2i):
	var score:int = 0
	var x = tile.x
	var y = tile.y
	
	score += 1 if _camino.has(Vector2(x,y-1)) else 0 #Score 1 = camino arriba
	score += 2 if _camino.has(Vector2(x+1,y)) else 0 #Score 2 = Camino derecha
	score += 4 if _camino.has(Vector2(x,y+1)) else 0 #Score 4 = Camino abajo
	score += 8 if _camino.has(Vector2(x-1,y)) else 0 #Score 8 = camino izquierda
	
	return score
