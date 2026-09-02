extends CardEffect
class_name DeployCharacterEffect

@export var character_scene : PackedScene

func apply(
	player : Player,
	grid_pos : Vector2i,
	board : GameBoard,
	char_parent : Node
) -> TestCharacter:
	var _char := character_scene.instantiate() as TestCharacter
	_char.owner_player = player.player_type
	char_parent.add_child(_char)
	_char.update_team_visual()
	_char.set_grid_position(grid_pos, board)
	player.characters.append(_char)
	
	return _char
