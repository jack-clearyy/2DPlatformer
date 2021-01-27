extends Area2D

export var next_scene: PackedScene

onready var anim_player: = $AnimationPlayer


func _on_Portal_area_entered(area: Area2D) -> void:
	# realistically, want to have the portal animation play here
	# have animation player call teleport function, which also fades out
	anim_player.play("Open")

func _get_configuration_warning() -> String:
	#if "" is returned, then no warning will be displayed
	return "The next scene property can't be empty" if not next_scene else ""

func teleport() -> void:
	get_tree().change_scene_to(next_scene)
