extends Control
class_name CardUI

signal card_clicked(card : CardData)
#signal card_hovered(card_ui : CardData)
#signal card_unhovered(card_ui : CardData)


@onready var card_name_label : Label = $CardName
@onready var cost_label : Label = $Cost
@onready var desc_label : Label = $Desc
@onready var artwork : TextureRect = $Artwork
@onready var card_frame : TextureRect = $Frame

var card_data : CardData

var normal_scale : Vector2 = Vector2.ONE
var hover_scale : Vector2 = Vector2(1.15, 1.15)


func _ready() -> void:
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	pivot_offset = Vector2(size.x / 2, size.y)


func setup(card : CardData) -> void:
	card_data = card
	
	card_name_label.text = card.card_name
	cost_label.text = str(card.energy_cost)
	desc_label.text = card.desc
	card_frame.texture = card.card_frame
	artwork.texture = card.card_artwork


func _on_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if card_data == null:
				return
			
			card_clicked.emit(card_data)


func _on_mouse_entered() -> void:
	scale = hover_scale
	position.y -= 30
	z_index = 10


func _on_mouse_exited() -> void:
	scale = normal_scale
	position.y += 30
	z_index = 0
