extends SmartObject
class_name so_ParkBench

@export var sit_rotation_y:float = 0.0

func perform_interaction(actor:ActorPed) -> bool:
	actor.global_rotation_degrees = global_rotation_degrees
	actor.is_sitting = true
	return false

func desperform_interaction(actor:ActorPed) -> bool:
	actor.current_action_slot.reset()
	actor.current_smart_object = null
	actor.is_sitting = false
	return false
