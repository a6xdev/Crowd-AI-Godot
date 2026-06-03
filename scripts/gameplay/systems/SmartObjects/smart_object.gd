extends Area3D
class_name SmartObject

@export_group("Debug")
@export var print_get_slot:bool = false

var slots:Array[ActionSlot] = []

#region GODOT FUNCTIONS
func _ready() -> void:
	# In a professional project, we should do the smart objects database based on the chunk that the player are
	# For now, all smart objects of the map will be in the same array.
	for child in get_children():
		if child is ActionSlot and not slots.has(child):
			child._smart_object_onwer = self
			slots.append(child)
#endregion

#region CALLS
func perform_interaction(actor:ActorPed) -> bool:
	return false

# Get out of the smart objects
func desperform_interaction(actor:ActorPed) -> bool:
	return false
	
func get_empty_slot() -> ActionSlot:
	for slot in slots:
		if not slot.is_taken:
			slot.is_taken = true
			return slot
	return null
#endregion
