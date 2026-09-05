extends RefCounted
class_name TestDeck

static func create_deck() -> Array[CardData]:
	var dash_card: CardData = preload("res://resources/cards/dash.tres")
	var energy_surge_card: CardData = preload("res://resources/cards/energy_surge.tres")
	var second_wind_card: CardData = preload("res://resources/cards/second_wind.tres")
	var deploy_character_card: CardData = preload("res://resources/cards/deploy_character.tres")
	
	var deck: Array[CardData] = [
		dash_card,
		dash_card,
		energy_surge_card,
		energy_surge_card,
		second_wind_card,
		second_wind_card,
		deploy_character_card,
		deploy_character_card,
		dash_card,
		energy_surge_card,
		dash_card,
		dash_card,
		energy_surge_card,
		energy_surge_card,
		second_wind_card,
		second_wind_card,
		deploy_character_card,
		deploy_character_card,
		dash_card,
		energy_surge_card,
	]
	
	deck.shuffle()
	return deck
