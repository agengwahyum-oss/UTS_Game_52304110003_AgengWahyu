extends CharacterBody3D

signal boost_changed(time_left: float, duration: float)

@export var move_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var boost_multiplier: float = 1.2
@export var boost_duration: float = 5.0

# Variabel status dienkapsulasi dengan awalan underscore (_)
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _boost_time_left: float = 0.0
var _active_multiplier: float = 1.2
var _active_duration: float = 5.0

@onready var _camera_pivot: Node3D = $CameraPivot
@onready var _body: Node3D = $body
@onready var _anim_player: AnimationPlayer = $body/AnimationPlayer

var _mouse_sensitivity: float = 0.003
var _camera_pitch: float = 0.0


func _ready() -> void:
	add_to_group("player")
	print("PLAYER SCRIPT AKTIF")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if _anim_player:
		print("Daftar animasi:", _anim_player.get_animation_list())


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_camera_pivot.rotate_y(-event.relative.x * _mouse_sensitivity)

			_camera_pitch -= event.relative.y * _mouse_sensitivity
			_camera_pitch = clampf(_camera_pitch, -1.0, 0.5)
			_camera_pivot.rotation.x = _camera_pitch

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	# Gravitasi
	if not is_on_floor():
		velocity.y -= _gravity * delta

	# Melompat
	if Input.is_physical_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = jump_velocity

	# Kontrol WASD langsung
	var input_dir := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_W):
		input_dir.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S):
		input_dir.y += 1.0
	if Input.is_physical_key_pressed(KEY_A):
		input_dir.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		input_dir.x += 1.0

	input_dir = input_dir.normalized()

	# Arah gerakan mengikuti kamera
	var camera_basis: Basis = _camera_pivot.global_transform.basis
	var direction: Vector3 = camera_basis.x * input_dir.x + camera_basis.z * input_dir.y
	direction.y = 0.0
	direction = direction.normalized()

	# Efek speed boost (+20% selama 5 detik)
	var current_speed: float = move_speed
	if _boost_time_left > 0.0:
		current_speed *= _active_multiplier

	if direction.length() > 0.0:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		# Putar badan karakter menghadap arah gerak
		var target_angle: float = atan2(direction.x, direction.z)
		_body.rotation.y = lerp_angle(_body.rotation.y, target_angle, 10.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, current_speed)
		velocity.z = move_toward(velocity.z, 0.0, current_speed)

	move_and_slide()
	_update_animation(direction)

	# Hitung mundur durasi boost melalui setter terenkapsulasi
	if _boost_time_left > 0.0:
		_set_boost_time_left(maxf(0.0, _boost_time_left - delta))


func _set_boost_time_left(new_time: float) -> void:
	_boost_time_left = new_time
	boost_changed.emit(_boost_time_left, _active_duration)


func _update_animation(direction: Vector3) -> void:
	if not _anim_player:
		return

	if not is_on_floor():
		if _anim_player.has_animation("air_jump"):
			_anim_player.play("air_jump")
	elif direction.length() > 0.0:
		if _anim_player.has_animation("run"):
			_anim_player.play("run")
	else:
		if _anim_player.has_animation("idle"):
			_anim_player.play("idle")


func apply_speed_boost(multiplier: float = boost_multiplier, duration: float = boost_duration) -> void:
	_active_multiplier = multiplier
	_active_duration = duration
	_set_boost_time_left(duration)
