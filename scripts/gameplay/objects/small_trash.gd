extends RigidBody3D


func _on_sleeping_state_changed() -> void:
	var new_event = Event.new()
