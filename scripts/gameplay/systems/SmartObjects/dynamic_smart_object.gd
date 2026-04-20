extends SmartObject
class_name DynamicSmartObject

enum DynamicActionType {
	LEAN_WALL_BACK,
	GROUP,
	NONE
}

@export var action_type:DynamicActionType = DynamicActionType.NONE

var collision_shape := CollisionShape3D.new()
var mesh := MeshInstance3D.new()
var slot := ActionSlot.new()

func _ready() -> void:
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(0.5, 0.5, 0.5)
	
	collision_shape.shape = BoxShape3D.new()
	mesh.mesh = box_mesh
	
	add_child(collision_shape)
	add_child(mesh)
	add_child(slot)
	
	slots.append(slot)

#region SYSTEM CALLS
func perform_interaction(actor:ActorPed) -> bool:
	match action_type:
		DynamicActionType.LEAN_WALL_BACK:
			actor.global_rotation_degrees = global_rotation_degrees
			actor.is_leaning_wall_back = true
		DynamicActionType.GROUP:
			pass
	return false

# Get out of the smart objects
func desperform_interaction(actor:ActorPed) -> bool:
	actor.is_leaning_wall_back = false
	return false
#endregion
