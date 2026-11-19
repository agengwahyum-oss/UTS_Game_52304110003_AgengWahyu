extends Control

@onready var _boost_bar: ProgressBar = $VBoxContainer/BoostBar
@onready var _boost_label: Label = $VBoxContainer/BoostLabel
@onready var _settings_panel: PanelContainer = $SettingsPanel
@onready var _title_label: Label = $SettingsPanel/VBoxContainer/TitleLabel
@onready var _sfx_slider: HSlider = $SettingsPanel/VBoxContainer/SfxSlider
@onready var _sfx_label: Label = $SettingsPanel/VBoxContainer/SfxLabel

var _sfx_bus_index: int = -1
var _max_boost_duration: float = 5.0
var _last_unmuted_volume: float = 100.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_boost_bar.visible = false
	_boost_label.visible = false
	_settings_panel.visible = false

	if _title_label:
		_title_label.text = "Pengaturan Audio\n[Tab] Buka/Tutup Panel  |  [M] Mute/Unmute SFX"

	_sfx_slider.min_value = 0.0
	_sfx_slider.max_value = 100.0
	_sfx_slider.step = 5.0

	_sfx_bus_index = AudioServer.get_bus_index("SFX")
	if _sfx_bus_index == -1:
		AudioServer.add_bus()
		_sfx_bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(_sfx_bus_index, "SFX")

	var is_muted := AudioServer.is_bus_mute(_sfx_bus_index)
	var initial_percent := 0.0 if is_muted else 100.0
	_sfx_slider.value = initial_percent
	_apply_sfx_volume(initial_percent)

	_sfx_slider.value_changed.connect(_on_sfx_slider_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_TAB:
			get_viewport().set_input_as_handled()
			_toggle_settings_panel()
		elif event.keycode == KEY_M:
			get_viewport().set_input_as_handled()
			_toggle_mute_sfx()

func _toggle_settings_panel() -> void:
	_settings_panel.visible = not _settings_panel.visible
	if _settings_panel.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
	else:
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _toggle_mute_sfx() -> void:
	if _sfx_bus_index == -1:
		return

	var is_currently_muted := AudioServer.is_bus_mute(_sfx_bus_index)
	if is_currently_muted:
		var restore_val := _last_unmuted_volume if _last_unmuted_volume > 0.0 else 100.0
		_sfx_slider.set_value_no_signal(restore_val)
		_apply_sfx_volume(restore_val)
	else:
		if _sfx_slider.value > 0.0:
			_last_unmuted_volume = _sfx_slider.value
		_sfx_slider.set_value_no_signal(0.0)
		_apply_sfx_volume(0.0)

func _on_sfx_slider_changed(value: float) -> void:
	if value > 0.0:
		_last_unmuted_volume = value
	_apply_sfx_volume(value)

func _apply_sfx_volume(percent: float) -> void:
	var muted := percent <= 0.0
	if _sfx_bus_index != -1:
		AudioServer.set_bus_mute(_sfx_bus_index, muted)
		if muted:
			AudioServer.set_bus_volume_db(_sfx_bus_index, -80.0)
		else:
			# Kurva perseptual -45 dB (5%) hingga 0 dB (100%) agar perbedaan volume terasa kontras
			var t := clampf(percent / 100.0, 0.0, 1.0)
			var target_db := lerpf(-45.0, 0.0, pow(t, 0.65))
			AudioServer.set_bus_volume_db(_sfx_bus_index, target_db)

	if muted:
		_sfx_label.text = "Volume SFX: 0% (MUTED)"
	else:
		_sfx_label.text = "Volume SFX: %d%%" % int(round(percent))

func on_player_boost_changed(time_left: float, max_duration: float = 5.0) -> void:
	if time_left > 0.0:
		if max_duration > 0.0:
			_max_boost_duration = max(max_duration, time_left)
		else:
			_max_boost_duration = max(_max_boost_duration, time_left)

		_boost_bar.min_value = 0.0
		_boost_bar.max_value = _max_boost_duration
		_boost_bar.value = time_left

		_boost_bar.visible = true
		_boost_label.visible = true
		_boost_label.text = "Speed Boost (+20%%): %.1fs" % time_left
	else:
		_boost_bar.visible = false
		_boost_label.visible = false
