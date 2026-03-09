extends RefCounted
class_name PedestrianState

var actor:ActorPed = null
var agent:FlowAIAgent3D
var brain:Node

func enter(): pass
func exit(): pass
func update(_delta:float): pass
