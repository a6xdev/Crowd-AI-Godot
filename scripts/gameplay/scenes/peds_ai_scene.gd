extends Node3D

@onready var flow_ai_controller: FlowAIController = $map/FlowAIController

func _ready() -> void:
	World.debug_state_changed.connect(_on_debug_state_changed)

func _on_debug_state_changed() -> void:
	flow_ai_controller.show_pathnode_shape = World.is_debugging
	flow_ai_controller.show_pathnode_lines = World.is_debugging
	flow_ai_controller.show_pathnode_label = World.is_debugging
