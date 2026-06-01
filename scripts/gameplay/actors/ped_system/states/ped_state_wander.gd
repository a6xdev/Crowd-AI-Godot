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
		# If the pedestrian walks enough, he looks for something to do
		if path_completed_index >= MAX_PATH_COMPLETED_INDEX and not actor.nearby_smart_objects.is_empty() and not actor.is_talking_phone:
			var obj_smart_obj = actor.nearby_smart_objects.pick_random()
			path_completed_index = 0
			if obj_smart_obj:
				actor.set_smart_object(obj_smart_obj)
		else:
			agent.get_random_path()
			index_already_gone_up = false
		return

	var target_pos = agent.get_next_pathnode_position()
	actor.move_dir = (target_pos - actor.global_position).normalized()
	actor.current_speed_type = ActorPed.SpeedType.WALK
	
	# idk if I will mantain this on release version, but looks good.
	if actor.velocity.length() < 0.1:
		_time_stopped += 1.0 * _delta
		if _time_stopped > 5.0:
			# Maybe this be defined in the spawn is a nice shot
			#var talking_phone_random:int = randi_range(0, 20)
			#if talking_phone_random == 3:
				#actor.is_talking_phone = true
			
			agent.get_random_path()
			index_already_gone_up = false
