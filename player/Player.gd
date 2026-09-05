extends Node
class_name Player

@export var player_type: PlayerOption.Type = PlayerOption.Type.PLAYER_ONE

@export var max_energy : int = 10
@export var starting_energy : int = 3
@export var energy_per_turn : int = 1

@export var cards_per_turn : int = 3
@export var max_hand_size : int = 10

var energy: int
var characters: Array[TestCharacter] = []

var deck: Array[CardData] = []
var hand: Array[CardData] = []
var discard_pile: Array[CardData] = []


func _ready() -> void:
	energy = starting_energy


func start_turn() -> void:
	gain_energy(energy_per_turn)
	reset_character_actions()


func gain_energy(amount: int) -> void:
	energy = min(energy + amount, max_energy)


func spend_energy(amount: int) -> bool:
	if energy < amount:
		return false
	
	energy -= amount
	return true


func draw_card() -> CardData:
	if deck.is_empty():
		reshuffle_discard()
	
	if deck.is_empty():
		return null
	
	var card : CardData = deck.pop_back()
	hand.append(card)
	
	return card


func draw_cards(amount : int) -> void:
	for i in amount:
		if hand.size() >= max_hand_size:
			return
		draw_card()


func reshuffle_discard() -> void:
	if discard_pile.is_empty():
		return
	
	deck.append_array(discard_pile)
	discard_pile.clear()
	deck.shuffle()


func play_card_from_hand(card : CardData) -> bool:
	if card not in hand:
		return false
	
	hand.erase(card)
	
	if card.card_type == CardData.CardType.REUSABLE:
		discard_pile.append(card)
	
	return true


func reset_character_actions() -> void:
	for character in characters:
		character.reset_actions()


func get_character_positions() -> Array[Vector2i]:
	var positions : Array[Vector2i] = []
	
	for character in characters:
		positions.append(character.grid_position)
	
	return positions


func get_character_at(grid_position : Vector2i) -> TestCharacter:
	for character in characters:
		if character.grid_position == grid_position:
			return character
	
	return null
