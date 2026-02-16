extends GOAPGoal
class_name AIGoalMoveAround

func is_valid(actor:ActorGoapPed) -> bool:
	actor.world_state.set("ai_want_move_around", true)
	return true

func get_desired_state() -> Dictionary:
	return {
		"ai_want_move_around" = false
	}
