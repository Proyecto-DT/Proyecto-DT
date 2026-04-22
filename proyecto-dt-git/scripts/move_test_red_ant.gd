extends CharacterBody3D

@onready var ruta_de_seguimiento = get_parent()

@export var speed = 30
var direccion: Vector3
var posicion_anterior: Vector3

func _ready():
	posicion_anterior = ruta_de_seguimiento.global_position

func _physics_process(delta: float) -> void:
	ruta_de_seguimiento.progress += speed * delta
