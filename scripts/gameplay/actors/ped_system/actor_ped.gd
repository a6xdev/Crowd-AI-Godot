extends CharacterBody3D
class_name ActorPed

var move_dir:Vector3 = Vector3.ZERO
var look_dir:Vector3 = Vector3.ZERO

enum SpeedType {
	WALK,
	RUN
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

var nearby_bodies:Array[ActorPed] = []
var nearby_smart_objects:Array[SmartObject] = []
var nearby_events:Array[Event] = []

var current_speed_type:SpeedType = SpeedType.WALK

var current_smart_object:SmartObject = null
var current_action_slot:ActionSlot = null
var current_event:Event = null

#region GODOT FUNCTIONS
func _physics_process(delta: float) -> void:
	animation_controller()
	movement_controller()
	orientation_controller()
	
	if not is_on_floor():
		# For some reason the normal gravity (9.8) is slow for this NPC.
		velocity.y -= 500.0 * delta
	
	move_and_slide()
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
	if ped_can_move and not is_sitting and is_on_floor():
		var avoidance_force = _get_avoidance_force()
		var final_dir = move_dir
		
		if avoidance_force != Vector3.ZERO:
			final_dir = (move_dir + avoidance_force * avoidance_side_weight).normalized()
		
		velocity = final_dir * _get_current_speed()
	else:
		velocity = Vector3.ZERO

func orientation_controller() -> void:
	if velocity.length() > 0.5:
		var to_target = atan2(move_dir.x, move_dir.z)
		rotation.y = lerp_angle(rotation.y, to_target, 0.2)
#endregion

#region CALLS
func set_event(event:Event) -> void:
	match event.event_type:
		Event.EventType.DANCE:
			var slot = event.get_free_slot(self)
		Event.EventType.AGRESSION:
			var slot = event.get_free_slot(self)

func set_action(smart_object:SmartObject) -> void:
	pass

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
#endregion
