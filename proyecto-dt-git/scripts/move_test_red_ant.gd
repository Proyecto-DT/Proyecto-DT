extends CharacterBody3D

@onready var path_follow = get_parent() # Asumiendo que es hijo de PathFollow2D

var speed = 50
var direccion: Vector3
var posicion_anterior: Vector3


func _ready():
	posicion_anterior = path_follow.global_position

func _physics_process(delta: float) -> void:
	path_follow.progress += speed * delta
