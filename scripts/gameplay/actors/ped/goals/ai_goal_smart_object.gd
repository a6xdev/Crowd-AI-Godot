extends GOAPGoal
class_name AIGoalSmartObject

func is_valid(actor:ActorGoapPed) -> bool:
	var valid = actor.nearby_smart_objects.size() > 0 and actor.world_state.get("ai_want_rest") == true
	if valid:
		var obj = actor.nearby_smart_objects.pop_front()
		if obj is SmartObject:
			var slot = obj.get_empty_slot()
			if slot:
				actor.world_state.set("ai_want_event", true)
				actor.current_action_slot = slot
				actor.current_smart_object = obj
				actor.current_target_position = slot.global_position
				return true
	return false

func get_desired_state() -> Dictionary:
	return {
		"ai_want_rest" = false
	}
