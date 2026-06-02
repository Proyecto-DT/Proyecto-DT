extends State

func entrar():
	print("¡Victoria! Oleada ", GameManager.oleada_actual, " completada")
	GestorPuntaje.finalizar_oleada()

func continuar():
	GameManager.oleada_actual += 1
	GestorMonedas.sumar_monedas(100)
	#game_manager.cambiar_estado("Preparacion")

#func salir_al_menu():
	#game_manager.cambiar_estado("Menu")

func salir():
	pass
