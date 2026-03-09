extends Node

@onready var actor_ped: ActorPed = $"../.."
@onready var agent: FlowAIAgent3D = $"../../FlowAIAgent3D"


var current_state:PedestrianState = null

#region GODOT FUNCTIONS
func _ready() -> void:
	change_state(PedStateWander.new())

func _physics_process(_delta: float) -> void:
	if current_state:
		current_state.update(_delta)
#endregion

#region CALLS
func change_state(new_state:PedestrianState) -> void:
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.actor = actor_ped
	current_state.agent = agent
	current_state.brain = self
	current_state.enter()
#endregion
