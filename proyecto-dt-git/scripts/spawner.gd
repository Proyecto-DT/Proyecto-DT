# Testeo
extends Node3D

@export var enemy_scene: PackedScene
@export var path_to_follow: Path3D
@export var total_enemies: int = 10
@export var spawn_delay: float = 1.0
@export var spawn_interval: float = 0.5

var enemies_spawned: int = 0
var spawning: bool = false

func _ready():
	start_spawning()

func start_spawning():
	spawning = true
	spawn_next_enemy()

func spawn_next_enemy():
	if enemies_spawned < total_enemies and spawning:
		spawn_enemy()
		enemies_spawned += 1
		
		# Programar el siguiente spawn
		await get_tree().create_timer(spawn_interval).timeout
		spawn_next_enemy()

func spawn_enemy():
	if not enemy_scene or not path_to_follow:
		print("Error: Faltan asignar la escena del enemigo o la ruta")
		return
	
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	
	# Configurar el enemigo
	if enemy.has_method("set_path"):
		enemy.set_path(path_to_follow)

func stop_spawning():
	spawning = false
