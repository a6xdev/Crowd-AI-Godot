extends GOAPAction

var smart_object_timer:float = 0.0

func init(actor:ActorGoapPed) -> bool:
	actor.world_state.set("ai_at_target_location", false)
	if actor.current_smart_object:
		actor.current_smart_object.perform_interaction(actor)
	return true

func execute(actor:ActorGoapPed) -> bool:
	if actor.current_event:
		actor.is_on_event = true
		
		if actor.current_event:
			actor.world_state.set("ai_want_event", false)
			actor.is_on_event = false
			return true
		
	elif actor.current_smart_object:
		smart_object_timer += 1.0 * get_physics_process_delta_time()
		
		if smart_object_timer >= 5.0:
			actor.current_smart_object.desperform_interaction(actor)
			actor.world_state.set("ai_want_event", false)
			actor.world_state.set("ai_want_rest", false)
			actor.current_action_slot = null
			actor.is_on_event = false
			smart_object_timer = 0.0
			return true
	return false

func exit(actor:ActorGoapPed) -> void:
	actor.move_dir = Vector3.ZERO

#region CALLS
func is_valid(actor:ActorGoapPed) -> bool:
	if actor.world_state.get("ai_want_event") or actor.world_state.get("ai_want_rest"):
		return true
	return false

func get_cost() -> int:
	return 1

# Action requirements.
func get_preconditions() -> Dictionary:
	return {
		"ai_at_target_location": true
	}

# What conditions this action satisfies
func get_effects() -> Dictionary:
	return {
		"ai_want_event": false,
		"ai_want_rest": false,
	}
