extends Node3D

@onready var board : GameBoard = $Board
@onready var player_one: Player = $PlayerOne
@onready var player_two: Player = $PlayerTwo
@onready var character : TestCharacter = $PlayerOne/Characters/TestCharacter

var selected_character : TestCharacter = null


func _ready() -> void:
	character.clicked.connect(_on_character_clicked)
	board.cell_clicked.connect(_on_cell_clicked)
	TurnManager.turn_started.connect(_on_turn_started)
	
	character.set_grid_position(Vector2i(1, 1), board)
	
	# TEMPORARY
	player_one.characters.append(character)
	
	TurnManager.start_turn()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.pressed:
			TurnManager.end_turn()


func _on_turn_started(player: PlayerOption.Type) -> void:
	if player == PlayerOption.Type.PLAYER_ONE:
		player_one.gain_energy(player_one.energy_per_turn)
		player_one.reset_character_actions()
		print("Energy: ", str(player_one.energy))
	else:
		player_two.gain_energy(player_two.energy_per_turn)
		player_two.reset_character_actions()
		print("Energy: ", str(player_two.energy))


func _on_character_clicked(clicked_character: TestCharacter) -> void:
	if clicked_character.owner_player != TurnManager.current_player:
		return
	
	selected_character = clicked_character
	
	print("Selected character!")
	print("Grid position: ", clicked_character.grid_position)
	print("Movement: ", clicked_character.movement)
	
	board.show_movement_range(clicked_character)


func _on_cell_clicked(cell: BoardCell) -> void:
	if selected_character == null:
		return
	
	if selected_character.owner_player != TurnManager.current_player:
		return
	
	if cell.grid_position == selected_character.grid_position:
		return
	
	var distance: int = (
		abs(cell.grid_position.x - selected_character.grid_position.x)
		+ abs(cell.grid_position.y - selected_character.grid_position.y)
	)
	
	if distance > selected_character.movement:
		return
	
	board.move_character(
		selected_character,
		cell.grid_position
	)
	
	board.clear_highlights()
	selected_character = null
