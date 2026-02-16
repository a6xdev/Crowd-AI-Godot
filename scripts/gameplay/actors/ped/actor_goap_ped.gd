extends CharacterBody3D
class_name ActorGoapPed

@onready var flow_ai_agent: FlowAIAgent3D = $FlowAIAgent3D
@onready var goal_selector: GOAPGoalSelector = $core/GOAP/GoalSelector
@onready var action_planer: GOAPActionPlanner = $core/GOAP/ActionPlaner

enum SpeedType {
	WALK,
	RUN
}

var move_dir:Vector3 = Vector3.ZERO
var look_dir:Vector3 = Vector3.ZERO

@export var world_state:Dictionary[String, Variant] = {
		"ai_is_going_to_place": false,
		
		"ai_at_target_location": false,
		
		"ai_want_move_around": false,
		"ai_want_event": false,
		"ai_want_rest": false,
	}

@export_group("Character Settings")
@export var ped_walk_speed:float = 2.0
@export var ped_run_speed:float = 5.0
@export var ped_rotation_speed:float = 8.0

@export_subgroup("Flags")
@export var ped_can_move:bool = true
@export var ped_can_rotate_body:bool = true
@export var can_despawn:bool = true

@export_group("Avoidance")
@export var avoidance_radius: float = 3.0
@export var avoidance_strength: float = 1.5
@export var avoidance_side_weight: float = 0.6

var is_stopped:bool = false
var is_walking:bool = false
var is_running:bool = false
var is_sitting:bool = false
var is_on_event:bool = false

var nearby_bodies:Array[ActorGoapPed] = []
var nearby_smart_objects:Array[SmartObject] = []
var nearby_events:Array[Event] = []

var current_speed_type:SpeedType = SpeedType.WALK
var current_target_position:Vector3 = Vector3(10.0, 0.0, 0.0)

var current_smart_object:SmartObject = null
var current_event:Event = null
var current_action_slot:ActionSlot = null
var goap_current_goal:GOAPGoal = null
var goap_current_plan:Array = []
var goap_current_action:GOAPAction = null

#region GODOT CALLS
func _ready() -> void:
	NpcManager.all_peds.append(self)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("d_action_01"):
		goap_current_goal = goal_selector.get_best_goal(self)
		goap_current_plan = action_planer.make_plan(self, goap_current_goal)
		print("current_goal: ", goap_current_goal)
		print("current_plan: ", goap_current_plan)
		print("\n")

func _physics_process(delta: float) -> void:
	animation_controller()
	movement_controller()
	orientation_controller()
	goap_controller()
	
	if not is_on_floor():
		velocity.y -= 9.8 * delta
#endregion

#region CONTROLLERS
func animation_controller() -> void:
	is_stopped = false if is_walking or is_running else true
	
	if velocity.length() > 3.0:
		is_walking = false
		is_running = true
	elif velocity.length() > 1.0:
		is_walking = true
		is_running = false
	else:
		is_walking = false
		is_running = false

func movement_controller() -> void:
	if ped_can_move and not is_sitting:
		var avoidance_force = _get_avoidance_force()
		var final_dir = move_dir
		
		if avoidance_force != Vector3.ZERO:
			final_dir = (move_dir + avoidance_force * avoidance_side_weight).normalized()
		
		velocity = final_dir * _get_current_speed()
		move_and_slide()
	else:
		velocity = Vector3.ZERO

func orientation_controller() -> void:
	if velocity.length() > 0.5:
		var to_target = atan2(move_dir.x, move_dir.z)
		rotation.y = lerp_angle(rotation.y, to_target, 0.2)

func goap_controller() -> void:
	if goap_current_action == null and not goap_current_plan.is_empty():
		var action = goap_current_plan.pop_front()
		action.init(self)
		goap_current_action = action
	
	if goap_current_action:
		var finished = goap_current_action.execute(self)
		if finished:
			#print("action_finished: ", goap_current_action)
			goap_current_action.exit(self)
			goap_current_action = null
		
#endregion

#region CALLS
func _get_avoidance_force() -> Vector3:
	var avoidance_force := Vector3.ZERO
	
	for body in nearby_bodies:
		if not is_instance_valid(body): 
			continue
			
		var to_body:Vector3 = body.global_position - global_position
		var d: float = to_body.length()
		var away = (global_position - body.global_position).normalized()
		var strength = (avoidance_radius - d) / avoidance_radius
		var side_step = away.cross(Vector3.UP) * 0.2
		
		avoidance_force += (away + side_step) * strength * avoidance_strength
			
	return avoidance_force

func _get_current_speed() -> float:
	match current_speed_type:
		SpeedType.WALK:
			return ped_walk_speed
		SpeedType.RUN:
			return ped_run_speed
	return 0.0

func get_best_event() -> Event:
	var best_event:Event = null
	var highest_dist:float = -1.0
	
	for event in nearby_events:
		if event is Event:
			var dist = event.global_position.distance_to(global_position)
			if dist > highest_dist:
				highest_dist = dist
				best_event = event
	
	current_event = best_event
	return best_event
#endregion

#region SIGNALS
# Sensor to nearby bodies (PEDs)
func _on_nearby_bodies_body_entered(body: Node3D) -> void:
	if body is ActorGoapPed:
		nearby_bodies.append(body)
func _on_nearby_bodies_body_exited(body: Node3D) -> void:
	if body is ActorGoapPed:
		nearby_bodies.erase(body)

# Sensor to nearby smart objects
func _on_nearby_smart_objects_body_entered(body: Node3D) -> void:
	if body is SmartObject:
		nearby_smart_objects.append(body)
func _on_nearby_smart_objects_body_exited(body: Node3D) -> void:
	if body is SmartObject:
		nearby_smart_objects.erase(body)
#endregion
