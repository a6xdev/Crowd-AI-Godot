extends Node
class_name PedsSpawnerController

const ACTOR_PED = preload("uid://c135kms22754d")

@export var SpawnerSlotsPath:Node = null
@export var SpawnerNpcPath:Node = null
@export var PedsGroupsPath:Node = null
@export var FlowAIControllerNode:FlowAIController = null

@export_group("Ped Spanwer Settings")
@export var active:bool = true
@export var peds_pool_size:int = 10
@export var spawn_radius:float = 100.0
@export var despawn_radius:float = 100.0

var peds_spawners:Array[PedsSpawnerSlot] = []

var init_spawn_radius:float = 0.0
var init_despawn_radius:float = 0.0

#region GODOT FUNCTIONS
func _ready() -> void:
	NpcManager.PedsSpawnerControllerNode = self
	
	init_spawn_radius = spawn_radius
	init_despawn_radius = despawn_radius
	
	await get_tree().process_frame
	
	var _to_create_spawner_slot:Array = []
	_to_create_spawner_slot.append_array(FlowAIControllerNode._get_pathnodes_list().values())
	_to_create_spawner_slot.append_array(NpcManager.smart_objects_slots)
	
	# Spawn peds in positions manually defined by me
	for i in SpawnerSlotsPath.get_children():
		if i is PedsSpawnerSlot:
			peds_spawners.append(i)
	
	# Object Pooling for the Peds
	for i in range(peds_pool_size):
		var actor_ped = ACTOR_PED.instantiate()
		SpawnerNpcPath.add_child(actor_ped)
		actor_ped.global_position = Vector3(0.0, -10.0, 0.0)
		actor_ped.process_mode = Node.PROCESS_MODE_DISABLED
		actor_ped.visible = false
		NpcManager.all_peds.append(actor_ped)
		NpcManager.inactive_peds.append(actor_ped)
	
	# Creates the PedsSpawnerSlot for each Pathnode of FlowAI pathnodes
	for _new_spawner_slot in _to_create_spawner_slot:
		var slot = PedsSpawnerSlot.new()
		var _spawn_pos:Vector3 = Vector3.ZERO
		
		if _new_spawner_slot is ActionSlot:
			slot.ped_spawner_type = PedsSpawnerSlot.SpawnerType.ACTION
			slot.m_smart_object = _new_spawner_slot.get_smart_object_owner()
		else:
			slot.ped_spawner_type = slot.SpawnerType.DEFAULT
		
		SpawnerSlotsPath.add_child(slot)
		slot.global_position = _new_spawner_slot.global_position
		peds_spawners.append(slot)

func _input(event: InputEvent) -> void:
	# Reload all the NPCs to show for the public.
	if Input.is_action_just_pressed("d_reload_npcs"):
		spawn_radius = 0.5
		despawn_radius = 0.6
		await get_tree().create_timer(0.5).timeout
		for slot in peds_spawners:
			slot.reset_spawn()
		spawn_radius = init_spawn_radius
		despawn_radius = init_despawn_radius
		
func _process(delta: float) -> void:
	if active:
		var current_camera_viewport := get_viewport().get_camera_3d()
		
		# Spawner Loop
		for slot in peds_spawners:
			var dist = slot.global_position.distance_to(current_camera_viewport.global_position)
			if slot.all_peds_in_slot.size() < slot.peds_size and dist <= spawn_radius and slot.can_spawn:
				while slot.all_peds_in_slot.size() < slot.peds_size:
					var ped = active_ped()
					if ped != null:
						ped.global_position = slot.global_position
						ped.global_position.y = slot.global_position.y
						ped.global_rotation.y = slot.global_rotation.y
						slot.set_ped_spawner_slot(ped)
					else:
						break
				break
			
			if slot.all_peds_in_slot.size() > 0:
				for ped in slot.all_peds_in_slot:
					if not ped.can_despawn: break
					
					var dist_to_ped = ped.global_position.distance_to(current_camera_viewport.global_position)
					if dist_to_ped >= despawn_radius and ped:
						disable_ped(ped)
						slot.clean_ped_spawner_slot(ped)
						break
		
		await get_tree().physics_frame
#endregion

#region CALLS
## Get and active a ped
func active_ped() -> ActorPed:
	if NpcManager.inactive_peds.is_empty():
		return null
	var actor_ped = NpcManager.inactive_peds.pop_back()
	actor_ped.process_mode = Node.PROCESS_MODE_INHERIT
	actor_ped.visible = true
	actor_ped.ped_reset()
	NpcManager.active_peds.append(actor_ped)
	return actor_ped

## Disable the ped
func disable_ped(ped:ActorPed) -> void:
	ped.global_position =  Vector3(0.0, -10.0, 0.0)
	ped.ped_reset()
	ped.visible = false
	NpcManager.active_peds.erase(ped)
	NpcManager.inactive_peds.append(ped)
	ped.process_mode = Node.PROCESS_MODE_DISABLED

## For PedsSpawnerSlot in differents scenes. Like in the park bench.
func registry_ped_spawner(spawn:PedsSpawnerSlot) -> void:
	if not peds_spawners.has(spawn):
		peds_spawners.append(spawn)
#endregion
