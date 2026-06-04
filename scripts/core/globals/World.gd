extends Node

var is_debugging:bool = false

signal debug_state_changed

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("d_draw_debug"):
		is_debugging = !is_debugging
		debug_state_changed.emit()
