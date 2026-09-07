# Main Menu
extends Control

@onready var play_button : Button = $Buttons/Play
@onready var decks_button : Button = $Buttons/Decks
@onready var shop_button : Button = $Buttons/Shop
@onready var settings_button : Button = $Buttons/Settings
@onready var back_button : Button = $Buttons/Back


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	decks_button.pressed.connect(_on_decks_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	back_button.pressed.connect(_on_back_pressed)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/Play/play_menu.tscn")


func _on_decks_pressed() -> void:
	pass


func _on_shop_pressed() -> void:
	pass


func _on_settings_pressed() -> void:
	pass


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/Start/start_menu.tscn")
