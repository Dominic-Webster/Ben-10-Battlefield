# Play Menu
extends Control

@onready var vs_ai_button : Button = $Buttons/VS_AI
@onready var join_button : Button = $Buttons/Join
@onready var host_button : Button = $Buttons/Host
@onready var back_button : Button = $Buttons/Back


func _ready() -> void:
	vs_ai_button.pressed.connect(_on_vs_ai_pressed)
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	back_button.pressed.connect(_on_back_pressed)


func _on_vs_ai_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/Match_Setup/match_setup.tscn")


func _on_host_pressed() -> void:
	pass


func _on_join_pressed() -> void:
	pass


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/Main/main_menu.tscn")
