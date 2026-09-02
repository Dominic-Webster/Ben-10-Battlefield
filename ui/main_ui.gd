extends CanvasLayer
class_name MainUI

signal end_turn_pressed
signal move_button_pressed
signal attack_button_pressed
signal ability_button_pressed

@onready var end_turn_button: Button = $EndTurn
@onready var character_actions_panel: Panel = $CharacterActionsPanel
@onready var move_button: Button = $CharacterActionsPanel/Move
@onready var attack_button: Button = $CharacterActionsPanel/Attack
@onready var ability_button: Button = $CharacterActionsPanel/Ability
@onready var status_label: Label = $StatusLabel
@onready var character_info_panel : Panel = $CharacterInfoPanel
@onready var char_name : Label = $CharacterInfoPanel/Name
@onready var char_hp : Label = $CharacterInfoPanel/Health


func _ready() -> void:
	# Hide character actions panel by default
	character_actions_panel.visible = false
	character_info_panel.visible = false
	
	# Connect button signals
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	move_button.pressed.connect(_on_move_pressed)
	attack_button.pressed.connect(_on_attack_pressed)
	ability_button.pressed.connect(_on_ability_pressed)


func show_character_panel(character: TestCharacter) -> void:
	character_actions_panel.visible = true
	character_info_panel.visible = true
	update_button_states(character)
	char_name.text = "Name: " + character.name
	char_hp.text = "Health: " + str(character.current_health) + "/" + str(character.max_health)


func hide_character_panel() -> void:
	character_actions_panel.visible = false
	character_info_panel.visible = false


func update_label(base_hp : int, max_hp : int, energy : int) -> void:
	if TurnManager.current_player == PlayerOption.Type.PLAYER_ONE:
		status_label.text = "Player: 1\nBase Health: " + str(base_hp) + "/" + str(max_hp) + "\nEnergy: " + str(energy)
	else:
		status_label.text = "Player: 2\nBase Health: " + str(base_hp) + "/" + str(max_hp) + "\nEnergy: " + str(energy)


func update_button_states(character: TestCharacter) -> void:
	move_button.disabled = not character.movement_available
	attack_button.disabled = not character.attack_available
	ability_button.disabled = not character.ability_available or character.ability == null
	if character.ability != null:
		ability_button.text = character.ability.ability_name


func _on_end_turn_pressed() -> void:
	end_turn_pressed.emit()


func _on_move_pressed() -> void:
	move_button_pressed.emit()


func _on_attack_pressed() -> void:
	attack_button_pressed.emit()


func _on_ability_pressed() -> void:
	ability_button_pressed.emit()
