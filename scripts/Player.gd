extends Node
class_name Player

@export var player_type: PlayerOption.Type = PlayerOption.Type.PLAYER_ONE

@export var max_energy : int = 10
@export var starting_energy : int = 3
@export var energy_per_turn : int = 1

var energy: int
var characters: Array[TestCharacter] = []


func _ready() -> void:
	energy = starting_energy


func gain_energy(amount: int) -> void:
	energy = min(energy + amount, max_energy)


func spend_energy(amount: int) -> bool:
	if energy < amount:
		return false
	
	energy -= amount
	return true

func reset_character_actions() -> void:
	for character in characters:
		character.reset_actions()
