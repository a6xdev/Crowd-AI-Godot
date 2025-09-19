extends Node
class_name ped_stimulus_controller

# Control the Ped Reaction to Event.

@export var npc:actor_npc = null
@export var agent:FlowAIAgent3D = null

#region GODOT FUNCTIONS

#endregion

#region CALLS
func set_event(event:Event) -> void:
	if not npc.current_event:
		npc.current_event = event
	else:
		if npc.current_event.event_priority <= npc.current_event.event_priority:
			npc.in_on_event = false
			npc.is_stopped = false
			npc.is_talking = false
			npc.is_dancing = false
			npc.is_stopped_on_event = false
			npc.look_current_event_target = Vector3.ZERO
			npc.current_event = event
			
	react_to_event()
	
func react_to_event() -> void:
	if not npc.current_event:
		return
	
	if npc.current_event:
		match npc.current_event.event_type:
			npc.current_event.EventType.DANCE:
				var slot = npc.current_event.get_free_slot()
				if slot:
					slot.slot_owner = npc
					npc.in_on_event = true
					npc.look_current_event_target = npc.current_event.global_position
					npc.navigation_set_event_path(npc.PathType.EVENT, slot.global_position)
					npc.current_event.event_involved_npcs.append(npc)
			npc.current_event.EventType.AGRESSION:
				pass
	
	if not npc.current_event.is_connected("event_finished", _on_current_event_finished):
		npc.current_event.event_finished.connect(_on_current_event_finished)
	
func timer_to_think() -> void: # Take a short brake before main reaction
	npc.is_standing = true
	await get_tree().create_timer(1.0).timeout
	npc.is_standing = false
#endregion

#region SIGNALS
func _on_current_event_finished(finished_event:Event) -> void:
	if finished_event == npc.current_event:
		npc.current_event = null
		npc.in_on_event = false
		npc.is_going_to_event_slot = false
		npc.is_stopped_on_event = false
		npc.is_dancing = false
		npc.is_talking = false
		npc.look_current_event_target = Vector3.ZERO
		npc.flow_ai_agent.target_position = Vector3.ZERO
#endregion
