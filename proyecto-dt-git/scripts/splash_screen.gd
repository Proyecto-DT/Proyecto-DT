extends Control

@export var siguiente_escena: PackedScene = preload("res://scenes/menu/menu.tscn")
var duracion_fade_in: float = 1.0
var tiempo_espera: float = 1.0
var duracion_fade_out: float = 1.0

@onready var logo = $ColorRect/CenterContainer/TextureRect

func _ready():
	print("SPLASH READY")
	fade()

func fade():
	logo.modulate.a = 0.0
	
	var tween = create_tween()
	tween.set_parallel(false)
	
	tween.tween_property(logo, "modulate:a", 1.0, duracion_fade_in)
	tween.tween_interval(tiempo_espera)
	tween.tween_property(logo, "modulate:a", 0.0, duracion_fade_out)
	
	await tween.finished
	get_tree().change_scene_to_packed(siguiente_escena)
