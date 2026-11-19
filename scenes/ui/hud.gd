extends Control

@onready var _boost_container: VBoxContainer = get_node_or_null("VBoxContainer")
@onready var _boost_bar: ProgressBar = get_node_or_null("VBoxContainer/BoostBar")
@onready var _boost_label: Label = get_node_or_null("VBoxContainer/BoostLabel")


func _ready() -> void:
	if _boost_container:
		_boost_container.visible = false


func on_player_boost_changed(time_left: float, duration: float) -> void:
	if not (_boost_container and _boost_bar and _boost_label):
		return

	if time_left > 0.0:
		_boost_container.visible = true
		_boost_bar.max_value = duration
		_boost_bar.value = time_left
		_boost_label.text = "Speed Boost (+20%%): %.1fs" % time_left
	else:
		_boost_container.visible = false
