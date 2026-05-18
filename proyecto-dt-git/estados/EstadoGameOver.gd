extends State

func entrar():
	print("Game Over - Puntaje final: ", GestorPuntaje.obtener_puntaje())
	get_tree().paused = true

func salir():
	pass
