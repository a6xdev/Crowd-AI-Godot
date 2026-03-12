extends PedestrianState
class_name PedStateAction

enum ActionType {
	EVENT,
	SMART_OBJECT,
	NONE
}

var current_action_type:ActionType = ActionType.NONE
var current_action_slot:ActionSlot = null

var timer_in_smart_object:float = 0.0

var is_executing_action:bool = false
var have_slot_target:bool = false

func _init(action_slot:ActionSlot, type:ActionType) -> void:
	current_action_slot = action_slot
	current_action_type = type

func enter():
	if current_action_slot:
		agent.set_target_position(current_action_slot.global_position)
		have_slot_target = true
	
	match current_action_type:
		ActionType.EVENT:
			actor.current_event.event_finished.connect(_on_event_finished)
		ActionType.SMART_OBJECT:
			pass

func exit():
	actor.is_on_event = false
	actor.is_in_smart_object = false
	actor.current_action_slot = null
	actor.current_event = null
	actor.current_smart_object = null
	current_action_slot = null

func update(_delta:float):
	if is_executing_action:
		match current_action_type:
			ActionType.EVENT:
				pass
			ActionType.SMART_OBJECT:
				timer_in_smart_object += 1.0 * _delta
				if actor.current_smart_object and timer_in_smart_object > 15.0:
					actor.current_smart_object.desperform_interaction(actor)
					await actor.get_tree().create_timer(1.0).timeout
					brain.change_state(PedStateWander.new())
	
	if have_slot_target:
		if agent.is_navigation_finished():
			actor.move_dir = Vector3.ZERO
			
			if not current_action_slot: return
			
			if actor.global_position != current_action_slot.global_position:
				actor.global_position = lerp(actor.global_position, current_action_slot.global_position, 5.0 * _delta)
			
			if actor.current_smart_object:
				actor.is_in_smart_object = true
				actor.current_smart_object.perform_interaction(actor)
			elif actor.current_event:
				actor.is_on_event = true
			
			is_executing_action = true
		else:
			var target_pos = agent.get_next_path_position()
			target_pos.y = actor.global_position.y
			
			actor.move_dir = (target_pos - actor.global_position).normalized()
			actor.current_speed_type = ActorPed.SpeedType.WALK

#region SIGNALS
func _on_event_finished(event:Event) -> void:
	brain.change_state(PedStateWander.new())
#endregion
