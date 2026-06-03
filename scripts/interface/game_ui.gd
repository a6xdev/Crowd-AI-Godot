extends CanvasLayer

@onready var peds_active_count: Label = $peds_count_backgorund/vbox/peds_active_count
@onready var peds_total_count: Label = $peds_count_backgorund/vbox/peds_total_count

func _process(delta: float) -> void:
	peds_active_count.text = "Active Peds: " + str(NpcManager.active_peds.size())
	peds_total_count.text = "Total Peds:   " + str(NpcManager.all_peds.size())
