extends Node3D

@onready var _player: CharacterBody3D = $Player
@onready var _hud: Control = $CanvasLayer/HUD


func _ready() -> void:
	if _player and _hud:
		_player.boost_changed.connect(_hud.on_player_boost_changed)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			get_tree().reload_current_scene()
