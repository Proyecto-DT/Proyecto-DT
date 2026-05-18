extends State

func entrar():
	print("Juego en pausa")
	get_tree().paused = true

func salir():
	get_tree().paused = false

func procesar_entrada(evento):
	pass
