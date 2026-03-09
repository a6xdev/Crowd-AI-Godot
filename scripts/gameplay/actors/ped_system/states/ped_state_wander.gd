extends PedestrianState
class_name PedStateWander

func enter():
	agent.get_random_path()

func exit():
	pass

func update(_delta:float):
	if agent.is_path_complete():
		agent.get_random_path()
		return
	
	var target_pos = agent.get_next_pathnode_position()
	var direction = (target_pos - actor.global_position).normalized()
	
	actor.move_dir = direction
	actor.current_speed_type = ActorPed.SpeedType.WALK
