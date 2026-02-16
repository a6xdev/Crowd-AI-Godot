extends GOAPGoal
class_name AIGoalEvent

func is_valid(actor:ActorGoapPed) -> bool:
	if actor.nearby_events.size() > 0:
		var event = actor.get_best_event()
		if event:
			var slot = actor.current_event.get_free_slot(actor)
			if slot:
				actor.world_state.set("ai_want_event", true)
				actor.current_action_slot = slot
				actor.current_event = event
				actor.current_target_position = slot.global_position
				return true
	return false

func get_desired_state() -> Dictionary:
	return {
		"ai_want_event" = false
	}
