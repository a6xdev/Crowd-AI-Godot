extends Marker3D
class_name PedSpawnerSlot

enum SpawnerType {
	SIT,
	GROUP,
	LEAN_WALL_BACK,
	DEFAULT
}

@export var ped_spawner_type:SpawnerType = SpawnerType.DEFAULT
@export var peds_size:int = 1

var can_spawn:bool = false

var all_peds_in_slot:Array[actor_npc] = []
var group_manager:PedGroupManager = null

func _ready() -> void:
	randomize()
	await get_tree().create_timer(0.5).timeout
	NpcManager.PedSpawnerControllerNode.registry_ped_spawner(self)

#region CALLS
func set_ped_spawner_slot(ped:actor_npc) -> void:
	if all_peds_in_slot.has(ped):
		return
	
	all_peds_in_slot.append(ped)
	
	match ped_spawner_type:
		SpawnerType.DEFAULT:
			# Peds default, they only will walk on the map
			pass
			
		SpawnerType.GROUP:
			# Create the group and set the peds
			if not group_manager:
				group_manager = PedGroupManager.new()
				add_child(group_manager)
				group_manager.generate_circle_slots(peds_size)
				
				var random = randi_range(0, 3)
				if random == 1:
					group_manager.current_group_state = group_manager.GroupState.WALKING
		
			if not group_manager.ped_group_owner:
				group_manager.ped_group_owner = all_peds_in_slot[0]
			
			group_manager.peds_in_group.append(ped)
			ped.current_group = group_manager
			
			var group_slot = group_manager.get_free_slot()
			if group_slot:
				group_slot.slot_owner = ped
				ped.global_position = group_slot.global_position
				ped.global_position.y = group_slot.global_position.y + 1
			
		SpawnerType.SIT:
			# Seated Peds
			
			# Need rotate ped based on spawn rotate
			ped.rotate_y(global_rotation.y)
			ped.look_current_path_target = global_position
			# Disable the movement to stay static.
			ped.ped_can_move = false
			ped.ped_can_rotate_body = false
			# Active the animation.
			ped.is_sitting = true
			
		SpawnerType.LEAN_WALL_BACK:
			# Ped leaning in the wall
			
			# Need rotate ped based on spawn rotate
			ped.rotate_y(global_rotation.y)
			ped.look_current_path_target = global_position
			# Disable the movement to stay static.
			ped.ped_can_move = false
			ped.ped_can_rotate_body = false
			# Active the animation
			ped.is_leaning_wall_back = true

# When the ped is despawned, the slot is cleared
func clean_ped_spawner_slot(ped:actor_npc) -> void:
	if all_peds_in_slot.has(ped):
		
		all_peds_in_slot.erase(ped)
		if group_manager and group_manager.peds_in_group.is_empty():
			group_manager.queue_free()

func reset_spawn():
	all_peds_in_slot.clear()
	can_spawn = false
	if group_manager: group_manager.queue_free()
#endregion
