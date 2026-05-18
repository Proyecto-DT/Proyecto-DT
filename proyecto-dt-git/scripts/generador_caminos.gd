extends Object
class_name GeneradorCaminos

var _cuadricula_longitud:int
var _cuadricula_latitud:int
var _loop_count:int

var _camino: Array[Vector2i]

func _init(longitud:int,latitud:int):
	_cuadricula_latitud = latitud
	_cuadricula_longitud = longitud

func generar_camino(add_loops:bool = false):
	_camino.clear()
	_loop_count = 0
	randomize()
	
	var x = 0 
	var y = int(_cuadricula_longitud/float(2))
	
	while x < _cuadricula_latitud:
		if not _camino.has(Vector2i(x,y)):
			_camino.append(Vector2i(x,y))
		
		var choice:int = randi_range(0,2)
		

		if choice == 0 or x % 2 == 0 or x == _cuadricula_latitud-1:
			x += 1
		elif choice == 1 and y < _cuadricula_longitud-2 and not _camino.has(Vector2i(x, y+1)):
			y += 1
		elif choice == 2 and y > 1 and not _camino.has(Vector2i(x, y-1)):
			y -= 1
		
	if add_loops:
		_add_loops()
		
	return _camino

func get_tile_score(index:int) -> int:
	var score:int = 0
	var x = _camino[index].x
	var y = _camino[index].y
	
	score += 1 if _camino.has(Vector2i(x-1,y)) else 0 # arriba
	score += 2 if _camino.has(Vector2i(x,y+1)) else 0 # derecha
	score += 4 if _camino.has(Vector2i(x+1,y)) else 0 # abajo
	score += 8 if _camino.has(Vector2i(x,y-1)) else 0 # izquierda
	
	return score
	
func obtener_camino() -> Array[Vector2i]:
	return _camino
	
func _add_loops():
	#  agrega loops
	var loops_generated:bool = true
	
	#genera loops hasta que no pueda mas
	
	while loops_generated:
		loops_generated = false
		for i in range(_camino.size()):
			var loop:Array[Vector2i] = _is_loop_option(i)
			#si el tamaño del loop es >0, entonces _is_loop_option encontro el loop y lo agregó
			if loop.size() > 0:
				loops_generated = true
				for j in range(loop.size()):
					if not _camino.has(loop[j]):
						_camino.insert(i+1+j, loop[j])
	var safety := 0

	while loops_generated and safety < 100:
		safety += 1

func _is_loop_option(index:int) -> Array[Vector2i]:
	var x: int = _camino[index].x
	var y: int = _camino[index].y
	var return_camino:Array[Vector2i]

	#Amarillo
	if (x < _cuadricula_latitud-3 and y > 2
		and _tile_loc_free(x, y-3) and _tile_loc_free(x+1, y-3) and _tile_loc_free(x+2, y-3)
		and _tile_loc_free(x-1, y-2) and _tile_loc_free(x, y-2) and _tile_loc_free(x+1, y-2) and _tile_loc_free(x+2, y-2) and _tile_loc_free(x+3, y-2)
		and _tile_loc_free(x-1, y-1) and _tile_loc_free(x, y-1) and _tile_loc_free(x+1, y-1) and _tile_loc_free(x+2, y-1) and _tile_loc_free(x+3, y-1)
		and _tile_loc_free(x+1,y) and _tile_loc_free(x+2,y) and _tile_loc_free(x+3,y)
		and _tile_loc_free(x+1,y+1) and _tile_loc_free(x+2,y+1)):
		return_camino = [Vector2i(x+1,y), Vector2i(x+2,y), Vector2i(x+2,y-1), Vector2i(x+2,y-2), Vector2i(x+1,y-2), Vector2i(x,y-2), Vector2i(x,y-1)]

		if index > 0 and _camino[index-1].y > y:
			return_camino.reverse()
			
		_loop_count += 1
		return_camino.append(Vector2i(x,y))

	#Azul
	elif (x > 2 and y > 1
			and _tile_loc_free(x, y-3) and _tile_loc_free(x-1, y-3) and _tile_loc_free(x-2, y-3)		
			and _tile_loc_free(x-1, y) and _tile_loc_free(x-2, y) and _tile_loc_free(x-3, y)
			and _tile_loc_free(x+1, y-1) and _tile_loc_free(x, y-1) and _tile_loc_free(x-2, y-1) and _tile_loc_free(x-3, y-1)
			and _tile_loc_free(x+1, y-2) and _tile_loc_free(x, y-2) and _tile_loc_free(x-1, y-2) and _tile_loc_free(x-2, y-2) and _tile_loc_free(x-3, y-2)
			and _tile_loc_free(x-1, y+1) and _tile_loc_free(x-2, y+1)):
		return_camino = [Vector2i(x,y-1), Vector2i(x,y-2), Vector2i(x-1,y-2), Vector2i(x-2,y-2), Vector2i(x-2,y-1), Vector2i(x-2,y), Vector2i(x-1,y)]

		if index > 0 and _camino[index-1].x > x:
			return_camino.reverse()

		_loop_count += 1
		return_camino.append(Vector2i(x,y))
	#Rojo
	elif (x < _cuadricula_latitud-3 and y < _cuadricula_longitud-3
			and _tile_loc_free(x, y+3) and _tile_loc_free(x+1, y+3) and _tile_loc_free(x+2, y+3)		
			and _tile_loc_free(x+1, y-1) and _tile_loc_free(x+2, y-1)
			and _tile_loc_free(x+1, y) and _tile_loc_free(x+2, y) and _tile_loc_free(x+3, y)
			and _tile_loc_free(x-1, y+1) and _tile_loc_free(x, y+1) and _tile_loc_free(x+2, y+1) and _tile_loc_free(x+3, y+1)
			and _tile_loc_free(x-1, y+2) and _tile_loc_free(x, y+2) and _tile_loc_free(x+1, y+2) and _tile_loc_free(x+2, y+2) and _tile_loc_free(x+3, y+2)):
		return_camino = [Vector2i(x+1,y), Vector2i(x+2,y), Vector2i(x+2,y+1), Vector2i(x+2,y+2), Vector2i(x+1,y+2), Vector2i(x,y+2), Vector2i(x,y+1)]

		if index > 0 and _camino[index-1].y < y:
			return_camino.reverse()
		
		_loop_count += 1
		return_camino.append(Vector2i(x,y))
	# Marron
	elif (x > 2 and y < _cuadricula_longitud-3
			and _tile_loc_free(x, y+3) and _tile_loc_free(x-1, y+3) and _tile_loc_free(x-2, y+3)
			and _tile_loc_free(x-1, y-1) and _tile_loc_free(x-2, y-1)
			and _tile_loc_free(x-1, y) and _tile_loc_free(x-2, y) and _tile_loc_free(x-3, y)
			and _tile_loc_free(x+1, y+1) and _tile_loc_free(x, y+1) and _tile_loc_free(x-2, y+1) and _tile_loc_free(x-3, y+1)
			and _tile_loc_free(x+1, y+2) and _tile_loc_free(x, y+2) and _tile_loc_free(x-1, y+2) and _tile_loc_free(x-2, y+2) and _tile_loc_free(x-3, y+2)):
		return_camino = [Vector2i(x,y+1), Vector2i(x,y+2), Vector2i(x-1,y+2), Vector2i(x-2,y+2), Vector2i(x-2,y+1), Vector2i(x-2,y), Vector2i(x-1,y)]

		if index > 0 and _camino[index-1].x > x:
			return_camino.reverse()
		
		_loop_count += 1
		return_camino.append(Vector2i(x,y))
		
	return return_camino
	
## Returns true if there is a path tile at the x,y coordinate.
func _tile_loc_taken(x: int, y: int) -> bool:
	return _camino.has(Vector2i(x,y))
	
## Returns true if there is no path tile at the x,y coordinate.
func _tile_loc_free(x: int, y: int) -> bool:
	if x < 0 or x >= _cuadricula_latitud:
		return false

	if y < 0 or y >= _cuadricula_longitud:
		return false

	return not _camino.has(Vector2i(x,y))

## Returns the number of loops currently in the path.
func get_loop_count() -> int:
	return _loop_count

## Returns the Vector2i path tile at the given index.
func get_path_tile(index:int) -> Vector2i:
	return _camino[index]
