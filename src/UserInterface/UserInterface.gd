extends Control

onready var scene_tree: = get_tree()
onready var pause_overlay: ColorRect = $PauseOverlay
onready var score: Label = $Label
onready var pause_title: Label = $PauseOverlay/Title
onready var death_lable: Label = $Death
onready var death_screen: ColorRect = $DeathScreen
var paused: = false setget set_paused

func _ready() -> void:
	PlayerData.connect("deaths_updated", self, "_on_PlayerData_player_died")
	update_interface()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		self.paused = not paused
		scene_tree.set_input_as_handled()

func update_interface() -> void:
	score.text = "Deaths: %s" % PlayerData.deaths

func _on_PlayerData_player_died() -> void:
	death_lable.visible = true
	death_screen.visible = true
	yield(get_tree().create_timer(1.5), "timeout")
	death_lable.visible = false
	death_screen.visible = false
	scene_tree.reload_current_scene()

func set_paused(value: bool) -> void:
	paused = value
	scene_tree.paused = value
	pause_overlay.visible = value
