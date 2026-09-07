extends Control

@onready var map_name : Label = $MapInfo/MapName
@onready var map_preview : TextureRect = $MapInfo/MapPreview

@onready var start_match_button : Button = $Buttons/StartMatch
@onready var back_button : Button = $Buttons/Back
@onready var deck1_button : Button = $DeckSelection/Decks/DeckSlot1
@onready var deck2_button : Button = $DeckSelection/Decks/DeckSlot2
@onready var deck3_button : Button = $DeckSelection/Decks/DeckSlot3

const TEST_DECK : DeckData = preload("res://resources/decks/test_deck.tres")
const TEST_MAP : MapData = preload("res://resources/maps/test_map.tres")

var available_maps : Array[MapData] = [
	TEST_MAP
]

var selected_deck : DeckData = null
var selected_map : MapData = null


func _ready() -> void:
	_select_random_map()
	
	start_match_button.pressed.connect(_on_start_match_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	deck1_button.pressed.connect(_on_deck_selected.bind(TEST_DECK))
	deck2_button.pressed.connect(_on_deck_selected.bind(TEST_DECK))
	deck3_button.pressed.connect(_on_deck_selected.bind(TEST_DECK))


func  _select_random_map() -> void:
	if available_maps.is_empty():
		push_error("No maps available.")
		return
	
	selected_map = available_maps.pick_random()
	
	map_name.text = "Map: " + selected_map.map_name
	map_preview.texture = selected_map.map_preview
	print("Selected map: ", selected_map.map_name)


func _on_start_match_pressed() -> void:
	if selected_deck == null:
		print("Please select a deck first.")
		return
	
	if selected_map == null:
		push_error("No map selected.")
		return
	
	MatchManager.player_one_deck = selected_deck
	MatchManager.player_two_deck = TEST_DECK
	MatchManager.selected_map = selected_map
	
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_deck_selected(deck : DeckData) -> void:
	selected_deck = deck
	print("Selected deck: ", deck.deck_name)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/Play/play_menu.tscn")
