@tool
extends SmartObject
class_name DynamicSmartObject

enum DynamicActionType {
	LEAN_WALL_BACK,
	LEAN_RAIL,
	GROUP,
	NONE
}

@export var action_type:DynamicActionType = DynamicActionType.LEAN_WALL_BACK

var collision_shape := CollisionShape3D.new()
var arrow := Arrow3D.new()
var slot := ActionSlot.new()

func _enter_tree() -> void:
	for child in get_children():
		if child is CollisionShape3D:
			return
	
	collision_shape.shape = BoxShape3D.new()
	add_child(collision_shape)
	add_child(arrow)

func _ready() -> void:
	if not Engine.is_editor_hint():
		add_child(slot)
		slots.append(slot)

#region SYSTEM CALLS
func perform_interaction(actor:ActorPed) -> bool:
	match action_type:
		DynamicActionType.LEAN_WALL_BACK:
			actor.global_rotation_degrees = global_rotation_degrees
			actor.is_leaning_wall_back = true
		DynamicActionType.LEAN_RAIL:
			actor.global_rotation_degrees = global_rotation_degrees
			# move the NPC to fit in the correct position
			actor.global_position += -actor.global_transform.basis.z.normalized() * 0.005
			actor.is_leaning_rail = true
		DynamicActionType.GROUP:
			pass
	return false

# Get out of the smart objects
func desperform_interaction(actor:ActorPed) -> bool:
	actor.is_leaning_wall_back = false
	# move the NPC back to avoid entering the object (NOTE: dont ask for me why i use the same formula to get closer and take him back. I also dont know)
	actor.global_position += -actor.global_transform.basis.z.normalized() * 0.01
	actor.is_leaning_rail = false
	for slot in slots:
		slot.reset()
	return false
#endregion
