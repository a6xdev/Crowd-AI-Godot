extends PedestrianState
class_name PedStateWander

func enter():
	agent.get_random_path()

func exit():
	actor.move_dir = Vector3.ZERO

func update(_delta:float):
	if agent.is_path_complete():
		agent.get_random_path()
		return
	else:
		var target_pos = agent.get_next_pathnode_position()
		actor.move_dir = (target_pos - actor.global_position).normalized()
		actor.current_speed_type = ActorPed.SpeedType.WALK
