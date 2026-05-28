extends PedestrianState
class_name PedStateWander

const MAX_PATH_COMPLETED_INDEX:int = 3

var path_completed_index:int = 0
var index_already_gone_up:bool = false
var _time_stopped:float = 0.0

func enter():
	agent.get_random_path()

func exit():
	actor.move_dir = Vector3.ZERO

func update(_delta:float):
	if agent.is_path_complete() and not index_already_gone_up:
		path_completed_index += 1
		index_already_gone_up = true
		if path_completed_index >= MAX_PATH_COMPLETED_INDEX and not actor.nearby_smart_objects.is_empty():
			var obj_smart_obj = actor.nearby_smart_objects.pick_random()
			path_completed_index = 0
			if obj_smart_obj:
				actor.set_smart_object(obj_smart_obj)
		else:
			agent.get_random_path()
			index_already_gone_up = false
		return
	else:
		var target_pos = agent.get_next_pathnode_position()
		actor.move_dir = (target_pos - actor.global_position).normalized()
		actor.current_speed_type = ActorPed.SpeedType.WALK
		
		if actor.velocity.length() < 0.1:
			_time_stopped += 1.0 * _delta
			if _time_stopped > 5.0:
				agent.get_random_path()
				index_already_gone_up = false
