extends SmartObject
class_name StaticSmartObject

#region SYSTEM CALLS
func perform_interaction(actor:ActorPed) -> bool:
	return false

# Get out of the smart objects
func desperform_interaction(actor:ActorPed) -> bool:
	return false
#endregion
