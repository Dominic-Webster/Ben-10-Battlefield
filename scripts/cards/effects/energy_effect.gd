extends CardEffect
class_name EnergyEffect

@export var energy_amount : int = 1


func apply(player : Player) -> void:
	player.gain_energy(energy_amount)
