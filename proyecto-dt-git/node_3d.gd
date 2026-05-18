extends Node3D

func _ready():
	print("node_3d cargado")
	GameManager.nivel_actual = self
	
	var spawner = _buscar_spawner(self)
	if spawner:
		spawner.estado_generador = false
		
		# conectar señal de todas las hormigas muertas
		if not spawner.todas_hormigas_muertas.is_connected(_on_todas_muertas):
			spawner.todas_hormigas_muertas.connect(_on_todas_muertas)
	
	# inicializar reina
	var reina = _buscar_reina(self)
	if reina:
		if not reina.reina_muerta.is_connected(_on_reina_muerta):
			reina.reina_muerta.connect(_on_reina_muerta)
		print("Reina encontrada y conectada")

func _buscar_spawner(nodo: Node) -> Node:
	for hijo in nodo.get_children():
		if hijo.has_method("siguiente_generacion_enemigo"):
			return hijo
		var encontrado = _buscar_spawner(hijo)
		if encontrado:
			return encontrado
	return null

func _buscar_reina(nodo: Node) -> Node:
	for hijo in nodo.get_children():
		if hijo.is_in_group("reina"):
			return hijo
		var encontrado = _buscar_reina(hijo)
		if encontrado:
			return encontrado
	return null

func _on_todas_muertas():
	print("node_3d: Todas las hormigas muertas")
	GameManager._on_victoria()

func _on_reina_muerta():
	print("node_3d: Reina muerta")
	GameManager._on_derrota()

func _input(event):
	if event.is_action_pressed("ui_accept") and GameManager.estado_actual == GameManager.EstadoJuego.PREPARACION:
		GameManager.cambiar_estado(GameManager.EstadoJuego.INVASION)
	
	if event.is_action_pressed("ui_cancel"):
		GameManager.cambiar_estado(GameManager.EstadoJuego.MENU)
