extends Marker3D
class_name ActionSlot

var is_taken:bool = false
var slot_owner:CharacterBody3D = null
var _smart_object_onwer:SmartObject = null

func _enter_tree() -> void:
	NpcManager.smart_objects_slots.append(self)

func _ready() -> void:
	#top_level = true
	
	if World.is_debugging:
		var w_mesh := MeshInstance3D.new()
		var w_mesh_material := StandardMaterial3D.new()

		w_mesh_material.albedo_color = Color(1, 0, 0)
		w_mesh.mesh = BoxMesh.new()
		w_mesh.mesh.size = Vector3(0.1, 0.1, 0.1)
		w_mesh.set_surface_override_material(0, w_mesh_material)
		
		add_child(w_mesh)
	
	_snap_to_ground()

func _process(delta: float) -> void:
	if OS.is_debug_build():
		DebugDraw3D.draw_sphere(global_position, 0.2, Color(0, 0, 1))

#region CALLS
func reset() -> void:
	is_taken = false
	slot_owner = null

func get_smart_object_owner() -> SmartObject:
	return _smart_object_onwer

func _snap_to_ground() -> void:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 2, global_position + Vector3.DOWN * 10)
	var result = space_state.intersect_ray(query)
	if result:
		var collider = result.get("collider")
		if collider is StaticBody3D: # I dont wanna the snap using characters as ground.
			global_position = result.position
#endregion
