extends Marker3D
class_name PedsSpawnerSlot

# This is a slot. When the player gets closer of this slot, the PedsSpawnerController will get some ped
# in the object pooling and put in this slot position

enum SpawnerType {
	DEFAULT,
	ACTION,
	IDLE,
}

@export var ped_spawner_type:SpawnerType = SpawnerType.DEFAULT
@export var ped_spawner_config:PedSpawnerConfig = PedSpawnerConfig.new()
@export var peds_size:int = 3
@export var can_spawn:bool = true

var m_smart_object:SmartObject = null
var all_peds_in_slot:Array[ActorPed] = []

#region GODOT FUNCTIONS
func _ready() -> void:
	randomize()
	await get_tree().create_timer(0.5).timeout
	NpcManager.PedsSpawnerControllerNode.registry_ped_spawner(self)

func _process(delta: float) -> void:
	if OS.is_debug_build() and World.is_debugging:
		DebugDraw3D.draw_arrow(global_position, Vector3(global_position.x, global_position.y + 1.0, global_position.z))
#endregion

#region CALLS
func set_ped_spawner_slot(ped:ActorPed) -> void:
	if all_peds_in_slot.has(ped):
		return
	
	ped.ped_can_move = ped_spawner_config.can_move
	all_peds_in_slot.append(ped)
	
	match ped_spawner_type:
		SpawnerType.DEFAULT:
			ped.pedestrian_brain.change_state(PedStateWander.new())
			return
		
		SpawnerType.ACTION:
			if m_smart_object:
				ped.is_talking_phone = false
				ped.set_smart_object(m_smart_object, true)
				return
			
		#SpawnerType.GROUP:
			## Create the group and set the peds
			#if not group_manager:
				#group_manager = PedGroupManager.new()
				#add_child(group_manager)
				#group_manager.generate_circle_slots(peds_size)
				#
				#var random = randi_range(0, 3)
				#if random == 1:
					#group_manager.current_group_state = group_manager.GroupState.WALKING
		#
			#if not group_manager.ped_group_owner:
				#group_manager.ped_group_owner = all_peds_in_slot[0]
			#
			#group_manager.peds_in_group.append(ped)
			#ped.current_group = group_manager
			#
			#var group_slot = group_manager.get_free_slot()
			#if group_slot:
				#group_slot.slot_owner = ped
				#ped.global_position = group_slot.global_position
				#ped.global_position.y = group_slot.global_position.y + 1

# When the ped is despawned, the slot is cleared
func clean_ped_spawner_slot(ped:ActorPed) -> void:
	if all_peds_in_slot.has(ped):
		all_peds_in_slot.erase(ped)
#endregion
