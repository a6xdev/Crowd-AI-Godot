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

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		var slot := ActionSlot.new()
		slot._smart_object_onwer = self
		add_child(slot)
		slots.append(slot)
	
	for child in get_children():
		if child is CollisionShape3D:
			return
	
	collision_shape.shape = BoxShape3D.new()
	add_child(collision_shape)
	add_child(arrow)

func _ready() -> void:
	if not Engine.is_editor_hint():
		set_collision_layer_value(1, false)
		set_collision_layer_value(6, true)
		set_collision_mask_value(1, false)


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
