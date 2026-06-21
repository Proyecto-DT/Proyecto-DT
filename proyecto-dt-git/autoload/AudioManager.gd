extends Node

# --- Música ---
var musica_actual: AudioStreamPlayer
var musica_menu: AudioStream = preload("res://assets/Sounds/Ambient/menu_music.mp3")
var musica_juego: AudioStream = preload("res://assets/Sounds/Ambient/game_music.mp3")

# --- Efectos de sonido ---
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS = 8

var sfx_library = {
	"ant_screech": preload("res://assets/Sounds/SFX/SFX_ant_screech_1.mp3"),
	"ant_steps": preload("res://assets/Sounds/SFX/SFX_ant_steps_1.mp3"),
	"event_2": preload("res://assets/Sounds/SFX/SFX_event_2.mp3"),
	"spawn_1": preload("res://assets/Sounds/SFX/SFX_spawn_1.mp3"),
	"spawn_2": preload("res://assets/Sounds/SFX/SFX_spawn_2.mp3"),
	"spawn_3": preload("res://assets/Sounds/SFX/SFX_spawn_3.mp3"),
	"ui_hover_1": preload("res://assets/Sounds/UI/UI_hover_menu_1.mp3"),
	"ui_hover_2": preload("res://assets/Sounds/UI/UI_hover_menu_2.mp3"),
	"ui_open_close": preload("res://assets/Sounds/UI/UI_open_close_menu_1.mp3"),
	"ui_select_1": preload("res://assets/Sounds/UI/UI_select_1.mp3"),
	"ui_select_2": preload("res://assets/Sounds/UI/UI_select_2.mp3"),
	"throwing": preload("res://assets/Sounds/SFX/SFX_Throwing.mp3"),
	"win": preload("res://assets/Sounds/SFX/SFX_Win.mp3"),
	"defeat": preload("res://assets/Sounds/SFX/SFX_defeat.mp3"),
}

func _ready():
	# Crear reproductores SFX
	for i in MAX_SFX_PLAYERS:
		var player = AudioStreamPlayer.new()
		add_child(player)
		sfx_players.append(player)
	
	# Crear reproductor de música
	musica_actual = AudioStreamPlayer.new()
	add_child(musica_actual)
	musica_actual.volume_db = -10
	musica_actual.finished.connect(_on_musica_terminada)
	
	print("AudioManager: musica_menu cargada? ", musica_menu != null)
	print("AudioManager: musica_juego cargada? ", musica_juego != null)

# ---- Música ----
func play_music(stream: AudioStream, fade_in: float = 0.0):
	if stream == null:
		push_error("AudioManager: stream es null")
		return

	if musica_actual.playing and musica_actual.stream == stream:
		return

	if musica_actual.playing:
		var tween = create_tween()
		tween.tween_property(musica_actual, "volume_db", -80, 0.3)
		await tween.finished
		musica_actual.stop()

	musica_actual.stream = stream

	if fade_in > 0:
		musica_actual.volume_db = -80
		musica_actual.play()

		var tween = create_tween()
		tween.tween_property(musica_actual, "volume_db", -10, fade_in)
	else:
		musica_actual.volume_db = -10
		musica_actual.play()

func stop_music(fade_out: float = 0.0):
	if not musica_actual.playing:
		return

	if fade_out > 0:
		var tween = create_tween()
		tween.tween_property(musica_actual, "volume_db", -80, fade_out)
		await tween.finished

	musica_actual.stop()
	musica_actual.volume_db = -10

func _on_musica_terminada():
	if musica_actual:
		musica_actual.play()

# ---- Métodos públicos para estados ----
func play_menu_music():
	print("AudioManager: play_menu_music()")
	play_music(musica_menu, 0.5)

func play_game_music():
	print("AudioManager: play_game_music()")

	if musica_juego == null:
		push_error("No se pudo cargar game_music.mp3")
		return

	play_music(musica_juego, 0.5)

func stop_music_with_fade():
	if musica_actual:
		print("AudioManager: stop_music_with_fade()")
		stop_music(0.5)
	else:
		print("AudioManager: no hay música para detener")

# ---- Efectos de sonido ----
func play_sfx(stream_key: String, volume_db: float = 0.0, pitch_scale: float = 1.0):
	var stream = sfx_library.get(stream_key)
	if not stream:
		push_warning("Sonido no encontrado: " + stream_key)
		return
	var player = _get_free_sfx_player()
	if not player:
		player = sfx_players[0]
		player.stop()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()

func _get_free_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	return null

# ---- Conveniencia ----
func ui_hover(): play_sfx("ui_hover_1", -5, randf_range(0.9, 1.1))
func ui_select(): play_sfx("ui_select_1", -3)
func ui_open_close(): play_sfx("ui_open_close", -3)
func spawn_enemy(): play_sfx("spawn_1", -2, randf_range(0.9, 1.1))
func enemy_dead(): play_sfx("ant_screech", -5, randf_range(0.8, 1.2))
func tower_placed(): play_sfx("spawn_3", -3)
func tower_shoot(): play_sfx("throwing", -5, randf_range(0.9, 1.1))
func victory(): play_sfx("win", -2)
func defeat(): play_sfx("defeat", -2)
