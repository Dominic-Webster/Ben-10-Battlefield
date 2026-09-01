extends Node3D
class_name GameBoard

signal cell_clicked(cell: BoardCell)

const CELL_SCENE = preload("res://scenes/board/cell.tscn")

@export var board_width: int = 8
@export var board_height: int = 8
@export var cell_size: float = 1.0

var selected_cell: BoardCell = null
var cells: Dictionary = {}
var highlighted_cells: Array[BoardCell] = []

func _ready() -> void:
	generate_board()


func generate_board() -> void:
	var offset_x := (board_width - 1) * cell_size / 2.0
	var offset_z := (board_height - 1) * cell_size / 2.0
	for x in board_width:
		for z in board_height:
			var cell := CELL_SCENE.instantiate()
			
			cell.grid_position = Vector2i(x, z)
			
			cell.position = Vector3(
				x * cell_size - offset_x,
				0,
				z * cell_size - offset_z
			)
			
			cells[cell.grid_position] = cell
			cell.clicked.connect(_on_cell_clicked)
			add_child(cell)


func _on_cell_clicked(cell: BoardCell) -> void:
	if selected_cell != null:
		selected_cell.unhighlight()
	
	selected_cell = cell
	selected_cell.highlight()
	
	cell_clicked.emit(cell)
	
	print("Selected cell: ", selected_cell.grid_position)


func get_cell(grid_position: Vector2i) -> BoardCell:
	return cells.get(grid_position)


func grid_to_world(grid_position: Vector2i) -> Vector3:
	var offset_x := (board_width - 1) * cell_size / 2.0
	var offset_z := (board_height - 1) * cell_size / 2.0
	
	return Vector3(
		grid_position.x * cell_size - offset_x,
		0,
		grid_position.y * cell_size - offset_z
	)


func get_cells_in_range(origin: Vector2i, _range: int) -> Array[BoardCell]:
	var cells_in_range: Array[BoardCell] = []
	
	for cell in cells.values():
		var distance : int = abs(cell.grid_position.x - origin.x) + abs(cell.grid_position.y - origin.y)
		
		if distance <= _range:
			cells_in_range.append(cell)
	
	return cells_in_range


func show_movement_range(character: TestCharacter) -> void:
	clear_highlights()
	
	var movement_cells: Array[BoardCell] = get_cells_in_range(
		character.grid_position,
		character.movement
	)
	
	for cell in movement_cells:
		if cell.grid_position != character.grid_position:
			cell.highlight()
			highlighted_cells.append(cell)


func clear_highlights() -> void:
	for cell in highlighted_cells:
		cell.unhighlight()
	
	highlighted_cells.clear()


func move_character(character: TestCharacter, destination: Vector2i) -> void:
	character.set_grid_position(destination, self)
	character.movement_available = false
