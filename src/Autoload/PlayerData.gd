extends Node

signal deaths_updated

var deaths: = 0 setget set_deaths, get_deaths
func rest() -> void:
	deaths = 0

func set_deaths(value: int) -> void:
	deaths = value
	emit_signal("deaths_updated")

func get_deaths() -> int:
	return deaths
