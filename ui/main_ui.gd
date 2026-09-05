extends CanvasLayer
class_name MainUI

signal end_turn_pressed
signal move_button_pressed
signal attack_button_pressed
signal ability_button_pressed

signal card_pressed(card : CardData)

@onready var player_info: Panel = $PlayerInfo
@onready var player_name: Label = $PlayerInfo/PlayerName
@onready var player_base_health: Label = $PlayerInfo/BaseHealth
@onready var player_energy: Label = $PlayerInfo/Energy

@onready var opponent_info: Panel = $OpponentInfo
@onready var opponent_name: Label = $OpponentInfo/PlayerName
@onready var opponent_base_health: Label = $OpponentInfo/BaseHealth
@onready var opponent_energy: Label = $OpponentInfo/Energy

@onready var character_popup: Panel = $CharacterPopup

@onready var character_actions_panel: Panel = $CharacterPopup/CharacterActionsPanel
@onready var move_button: Button = $CharacterPopup/CharacterActionsPanel/Move
@onready var attack_button: Button = $CharacterPopup/CharacterActionsPanel/Attack
@onready var ability_button: Button = $CharacterPopup/CharacterActionsPanel/Ability

@onready var character_info_panel: Panel = $CharacterPopup/CharacterInfoPanel
@onready var char_name: Label = $CharacterPopup/CharacterInfoPanel/Name
@onready var char_hp: Label = $CharacterPopup/CharacterInfoPanel/Health

@onready var hand : Control = $BottomBar/Hand
@onready var draw_count: Label = $BottomBar/DrawPile/Count
@onready var discard_count: Label = $BottomBar/DiscardPile/Count

@onready var end_turn_button: Button = $BottomBar/EndTurn

const CARD_UI_SCENE = preload("res://ui/cards/CardUI.tscn")


func _ready() -> void:
	character_popup.visible = false
	
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	move_button.pressed.connect(_on_move_pressed)
	attack_button.pressed.connect(_on_attack_pressed)
	ability_button.pressed.connect(_on_ability_pressed)


func refresh_hand(cards : Array[CardData]) -> void:
	for child in hand.get_children():
		child.queue_free()
	
	if cards.is_empty():
		return
	
	var max_spacing : float = 150.0
	var available_width : float = hand.size.x - 130.0
	
	var card_spacing : float = min(
		max_spacing,
		available_width / max(cards.size() - 1, 1)
	)
	
	for i in cards.size():
		var card_ui: CardUI = CARD_UI_SCENE.instantiate()
		hand.add_child(card_ui)
		card_ui.setup(cards[i])
		connect_card(card_ui)
		
		card_ui.position = Vector2(i * card_spacing, 0)


func refresh_piles(player: Player) -> void:
	draw_count.text = "Draw\n" + str(player.deck.size())
	discard_count.text = "Discard\n" + str(player.discard_pile.size())


func highlight_current_player(player: PlayerOption.Type) -> void:
	player_info.modulate = Color(0.7, 0.7, 0.7)
	opponent_info.modulate = Color(0.7, 0.7, 0.7)
	
	if player == PlayerOption.Type.PLAYER_ONE:
		player_info.modulate = Color.WHITE
	else:
		opponent_info.modulate = Color.WHITE


func show_character_panel(character: TestCharacter) -> void:
	character_popup.visible = true
	
	update_button_states(character)
	
	char_name.text = "Name: " + character.name
	char_hp.text = "Health: " + str(character.current_health) + "/" + str(character.max_health)
	
	var camera := character.get_viewport().get_camera_3d()
	
	if camera == null:
		return
	
	var screen_position := camera.unproject_position(character.global_position)
	
	character_popup.position = screen_position + Vector2(30, -100)


func hide_character_panel() -> void:
	character_popup.visible = false


func update_player_info(base_hp: int, max_hp: int, energy: int) -> void:
	player_name.text = "PLAYER 1"
	player_base_health.text = "Base Health: " + str(base_hp) + "/" + str(max_hp)
	player_energy.text = "Energy: " + str(energy) + "/10"


func update_opponent_info(base_hp: int, max_hp: int, energy: int) -> void:
	opponent_name.text = "PLAYER 2"
	opponent_base_health.text = "Base Health: " + str(base_hp) + "/" + str(max_hp)
	opponent_energy.text = "Energy: " + str(energy) + "/10"


func update_button_states(character: TestCharacter) -> void:
	move_button.disabled = not character.movement_available
	attack_button.disabled = not character.attack_available
	ability_button.disabled = not character.ability_available or character.ability == null
	
	if character.ability != null:
		ability_button.text = character.ability.ability_name


func connect_card(card_ui: CardUI) -> void:
	card_ui.card_clicked.connect(_on_card_clicked)


func _on_card_clicked(card: CardData) -> void:
	card_pressed.emit(card)


func _on_end_turn_pressed() -> void:
	end_turn_pressed.emit()


func _on_move_pressed() -> void:
	move_button_pressed.emit()


func _on_attack_pressed() -> void:
	attack_button_pressed.emit()


func _on_ability_pressed() -> void:
	ability_button_pressed.emit()
