extends StaticSmartObject
class_name SmartObjectSitAction

func perform_interaction(actor:ActorPed) -> bool:
	actor.global_rotation_degrees = global_rotation_degrees
	actor.global_position += -actor.global_transform.basis.z.normalized() * 0.03
	actor.is_sitting = true
	return false

func desperform_interaction(actor:ActorPed) -> bool:
	actor.global_position += -actor.global_transform.basis.z.normalized() * 0.01
	actor.current_action_slot.reset()
	actor.current_smart_object = null
	actor.is_sitting = false
	return false
