class_name BlueCrystal
extends Area3D

signal crystal_collected(duration: float)

@export var _speed_multiplier: float = 1.2
@export var _boost_duration: float = 5.0
@export var _rotate_speed: float = 2.5
@export var _respawn_time: float = 6.0

var _is_collected: bool = false

@onready var _sfx_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var _mesh: MeshInstance3D = $MeshInstance3D
@onready var _collider: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	rotate_y(_rotate_speed * delta)


func _on_body_entered(body: Node3D) -> void:
	if _is_collected:
		return

	if body.is_in_group("player") and body.has_method("apply_speed_boost"):
		_is_collected = true
		body.apply_speed_boost(_speed_multiplier, _boost_duration)
		crystal_collected.emit(_boost_duration)

		_mesh.visible = false
		_collider.set_deferred("disabled", true)

		await _play_crystal_chime()
		await get_tree().create_timer(_respawn_time).timeout
		_respawn()


func _respawn() -> void:
	_is_collected = false
	_mesh.visible = true
	_collider.set_deferred("disabled", false)


func _play_crystal_chime() -> void:
	if not _sfx_player:
		return

	var generator := AudioStreamGenerator.new()
	generator.mix_rate = 44100.0
	generator.buffer_length = 0.55
	_sfx_player.stream = generator
	_sfx_player.bus = "SFX"
	_sfx_player.play()

	var playback: AudioStreamGeneratorPlayback = _sfx_player.get_stream_playback()
	if not playback:
		return

	# Nada arpeggio kristal naik: C6 (1046.5 Hz), E6 (1318.5 Hz), G6 (1568 Hz), C7 (2093 Hz)
	var notes: Array[float] = [1046.5, 1318.5, 1568.0, 2093.0]
	var note_duration: float = 0.11
	var sample_rate: float = generator.mix_rate

	for note_idx in range(notes.size()):
		var freq: float = notes[note_idx]
		var frames: int = int(sample_rate * note_duration)
		for i in range(frames):
			var t: float = float(i) / sample_rate
			var envelope: float = exp(-t * 14.0) # Efek denting bel kristal (decay halus)
			var wave: float = (sin(TAU * freq * t) * 0.65 + sin(TAU * freq * 2.0 * t) * 0.25) * envelope
			playback.push_frame(Vector2(wave, wave))

	await get_tree().create_timer(0.48).timeout
