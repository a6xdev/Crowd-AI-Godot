extends SmartObject
class_name DynamicSmartObject

enum DynamicActionType {
	LEAN_WALL_BACK,
	SIT,
	GROUP,
	NONE
}

@export var action_type:DynamicActionType = DynamicActionType.NONE

#region SYSTEM CALLS
func perform_interaction(actor:ActorPed) -> bool:
	return false

# Get out of the smart objects
func desperform_interaction(actor:ActorPed) -> bool:
	return false
#endregion
