extends PedestrianState
class_name PedStateWander

# The Ped will walk, and walk, and, walk, and walk, and walk... until he wants to interact with some smart object

var path_completed_index:int = 0
var index_already_gone_up:bool = false
var _time_stopped:float = 0.0
var _max_path_completed_index:int = 3
var _max_time_stopped:float = 5.0

func enter():
	_max_path_completed_index = randi_range(3, 6)
	_max_time_stopped = randf_range(3.0, 6.0)
	agent.get_random_path()

func exit():
	actor.move_dir = Vector3.ZERO

func update(_delta:float):
	# logic for when peds reaches the end of the path
	if agent.is_path_complete() and not index_already_gone_up:
		path_completed_index += 1
		index_already_gone_up = true
		
		# If the pedestrian walks enough, he looks for something to do
		var walked_enough:bool = path_completed_index >= _max_path_completed_index
		var can_interact:bool = not actor.nearby_smart_objects.is_empty() and not actor.is_talking_phone
		if walked_enough and can_interact:
			var obj_smart_obj = actor.nearby_smart_objects.pick_random()
			if obj_smart_obj:
				path_completed_index = 0
				index_already_gone_up = false
				actor.set_smart_object(obj_smart_obj)
				return
			
			index_already_gone_up = false
			agent.get_random_path()
			return
	
	# Movement logic here
	var target_pos = agent.get_next_pathnode_position()
	actor.move_dir = (target_pos - actor.global_position).normalized()
	actor.current_speed_type = ActorPed.SpeedType.WALK
	
	# idk if I will mantain this on release version, but looks good.
	if actor.velocity.length() < 0.1:
		_time_stopped += 1.0 * _delta
		if _time_stopped > _max_time_stopped:
			# NOTE: maybe we can form groups with nearby peds when stop.
			
			# Maybe this be defined in the spawn is a nice shot
			#var talking_phone_random:int = randi_range(0, 20)
			#if talking_phone_random == 3:
				#actor.is_talking_phone = true
			
			agent.get_random_path()
			index_already_gone_up = false
