extends Node3D

enum GameMode {
	NORMAL_SELECTION,
	MOVEMENT_MODE,
	ATTACK_MODE,
	ABILITY_MODE,
	CARD_TARGET_MODE,
	SECOND_WIND_MODE
}

@onready var board : GameBoard = $Board
@onready var player_one: Player = $PlayerOne
@onready var player_two: Player = $PlayerTwo
@onready var character : TestCharacter = $PlayerOne/Characters/TestCharacter
@onready var character2 : TestCharacter = $PlayerTwo/Characters/TestCharacter
@onready var character3 : TestCharacter = $PlayerOne/Characters/TestCharacter2
@onready var character4 : TestCharacter = $PlayerTwo/Characters/TestCharacter2
@onready var player_one_base: Base = $PlayerOneBase
@onready var player_two_base: Base = $PlayerTwoBase
@onready var ui: MainUI = $MainUI

var current_player : Player
var selected_character : TestCharacter = null
var pending_card : CardData = null
var current_mode : GameMode = GameMode.NORMAL_SELECTION
var highlighted_targets : Array[TestCharacter] = []
var highlighted_bases : Array[Base] = []
var game_over : bool = false

# TEMP
var dash_card : CardData = preload("res://resources/cards/dash.tres")
var energy_surge_card: CardData = preload("res://resources/cards/energy_surge.tres")
var second_wind_card : CardData = preload("res://resources/cards/second_wind.tres")
var deploy_character_card : CardData = preload("res://resources/cards/deploy_character.tres")

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if not event.pressed:
			return
		
		if current_mode == GameMode.SECOND_WIND_MODE:
			if selected_character == null:
				return
			
			if event.keycode == KEY_M:
				_restore_second_wind_action(
					SecondWindEffect.ActionType.MOVEMENT
				)
			
			elif event.keycode == KEY_A:
				_restore_second_wind_action(
					SecondWindEffect.ActionType.ATTACK
				)
			
			elif event.keycode == KEY_B:
				_restore_second_wind_action(
					SecondWindEffect.ActionType.ABILITY
				)
			
			return
		
		if event.keycode == KEY_D:
			play_card(dash_card)
		
		if event.keycode == KEY_E:
			play_card(energy_surge_card)
		
		if event.keycode == KEY_S:
			play_card(second_wind_card)
		
		if event.keycode == KEY_P:
			play_card(deploy_character_card)


func _restore_second_wind_action(action_type : SecondWindEffect.ActionType) -> void:
	if selected_character == null:
		return
	
	match action_type:
		SecondWindEffect.ActionType.MOVEMENT:
			if selected_character.movement_available:
				print("Movement is already available.")
				return

		SecondWindEffect.ActionType.ATTACK:
			if selected_character.attack_available:
				print("Attack is already available.")
				return

		SecondWindEffect.ActionType.ABILITY:
			if selected_character.ability_available:
				print("Ability is already available.")
				return
	
	if not current_player.spend_energy(pending_card.energy_cost):
		print("Not enough energy!")
		return
	
	for effect in pending_card.effects:
		if effect is SecondWindEffect:
			effect.apply(selected_character, action_type)
	
	print("Restored action on ", selected_character.name)
	
	current_mode = GameMode.NORMAL_SELECTION
	selected_character = null
	pending_card = null
	_clear_target_highlights()
	board.clear_highlights()


func _ready() -> void:
	# Connect character signals
	character.clicked.connect(_on_character_clicked)
	character2.clicked.connect(_on_character_clicked)
	character3.clicked.connect(_on_character_clicked)
	character4.clicked.connect(_on_character_clicked)
	
	# Connect board signals
	board.cell_clicked.connect(_on_cell_clicked)
	
	# Connect turn signals
	TurnManager.turn_started.connect(_on_turn_started)
	
	# Connect UI signals
	ui.end_turn_pressed.connect(_on_end_turn_pressed)
	ui.move_button_pressed.connect(_on_move_button_pressed)
	ui.attack_button_pressed.connect(_on_attack_button_pressed)
	ui.ability_button_pressed.connect(_on_ability_button_pressed)
	
	# Connect base signals
	player_one_base.clicked.connect(_on_base_clicked)
	player_two_base.clicked.connect(_on_base_clicked)
	
	# TEMPORARY CHARACTER SETUP
	character.set_grid_position(Vector2i(1, 1), board)
	character2.set_grid_position(Vector2i(6, 6), board)
	character3.set_grid_position(Vector2i(1, 6), board)
	character4.set_grid_position(Vector2i(6, 1), board)
	player_one.characters.append(character)
	player_two.characters.append(character2)
	player_one.characters.append(character3)
	player_two.characters.append(character4)
	
	# Register base cells
	board.register_base(player_one_base, [Vector2i(0, 3), Vector2i(0, 4)])
	board.register_base(player_two_base, [Vector2i(7, 3), Vector2i(7, 4)])
	
	TurnManager.start_turn()


# ============================================
# TURN MANAGEMENT
# ============================================

func _on_turn_started(player: PlayerOption.Type) -> void:
	if game_over:
		return

	if player == PlayerOption.Type.PLAYER_ONE:
		current_player = player_one
		player_one.start_turn()
		
		ui.update_label(
			player_one_base.current_health,
			player_one_base.max_health,
			player_one.energy
		)
		
		print("Player 1 Turn")
		print("Energy: ", str(player_one.energy))
		
	else:
		current_player = player_two
		player_two.start_turn()
		
		ui.update_label(
			player_two_base.current_health,
			player_two_base.max_health,
			player_two.energy
		)
		
		print("Player 2 Turn")
		print("Energy: ", str(player_two.energy))


func _on_end_turn_pressed() -> void:
	if game_over:
		return
	
	_clear_target_highlights()
	board.clear_highlights()
	
	ui.hide_character_panel()
	
	selected_character = null
	current_mode = GameMode.NORMAL_SELECTION
	
	TurnManager.end_turn()


# =========================================
# CHARACTER SELECTION
# =========================================

func _on_character_clicked(clicked_character: TestCharacter) -> void:
	if game_over:
		return
	
	# Card targeting
	if current_mode == GameMode.CARD_TARGET_MODE:
		_handle_card_target(clicked_character)
		return
	
	# Teleport does not target characters
	# Ignor character clicks while teleport is active
	if current_mode == GameMode.ABILITY_MODE:
		if selected_character != null and selected_character.ability != null:
			if selected_character.ability.ability_type == AbilityData.AbilityType.TELEPORT:
				return
	
	# Handle clicking an enemy while using a damage ability
	if current_mode == GameMode.ABILITY_MODE and selected_character != null:
		if clicked_character.owner_player != selected_character.owner_player:
			if _try_use_ability_on_character(clicked_character):
				return
	
	# Handle clicking an enemy while attacking
	if current_mode == GameMode.ATTACK_MODE and selected_character != null:
		if clicked_character.owner_player != selected_character.owner_player:
			if _try_attack_character(clicked_character):
				return
	
		# Exit attack mode if clicking on own character
		_cancel_current_mode()
		return
	
	# Only allow selecting characters belonging to the current player
	if clicked_character.owner_player != TurnManager.current_player:
		return
	
	_clear_target_highlights()
	board.clear_highlights()
	
	selected_character = clicked_character
	current_mode = GameMode.NORMAL_SELECTION
	
	print("Selected character!")
	print("Grid position: ", clicked_character.grid_position)
	print("Movement: ", clicked_character.movement)
	
	ui.show_character_panel(clicked_character)


# ======================================================
# CARDS
# ======================================================

func play_card(card: CardData) -> void:
	if current_player == null:
		return
	
	if current_player.energy < card.energy_cost:
		print("Not enough energy to play ", card.card_name)
		return
	
	match card.target_type:
		CardData.TargetType.NONE:
			_play_card(card)
		
		CardData.TargetType.CHARACTER:
			pending_card = card
			current_mode = GameMode.CARD_TARGET_MODE
			_show_card_character_targets()
		
		CardData.TargetType.CELL:
			pending_card = card
			current_mode = GameMode.CARD_TARGET_MODE
			_show_card_cell_targets()


func _play_card(card: CardData) -> void:
	if not current_player.spend_energy(card.energy_cost):
		return
	
	for effect in card.effects:
		if effect is EnergyEffect:
			effect.apply(current_player)
	
	print("Played ", card.card_name)


func _show_card_character_targets() -> void:
	board.clear_highlights()
	_clear_target_highlights()
	
	if pending_card == null:
		return
	
	for player in [player_one, player_two]:
		for _character in player.characters:
			if _character.owner_player == current_player.player_type:
				_character.highlight_as_target()
				highlighted_targets.append(_character)


func _show_card_cell_targets() -> void:
	board.clear_highlights()
	
	for x in range(8):
		for y in range(8):
			var grid_pos := Vector2i(x, y)
			
			if current_player.player_type == PlayerOption.Type.PLAYER_ONE:
				if x > 1:
					continue
			else:
				if x < 6:
					continue
			
			if board.is_base_cell(grid_pos) or _is_cell_occupied(grid_pos):
				continue
			
			var cell := board.get_cell(grid_pos)
			
			if cell != null:
				cell.highlight_movement()
				board.highlighted_cells.append(cell)


func _handle_card_target(target: TestCharacter) -> void:
	if pending_card == null:
		return
	
	if target.owner_player != current_player.player_type:
		return
	
	if pending_card.effects.any(
		func(effect): return effect is SecondWindEffect
	):
		selected_character = target
		current_mode = GameMode.SECOND_WIND_MODE
		_clear_target_highlights()
		print("Choose an action to restore.")
		return
	
	if not current_player.spend_energy(pending_card.energy_cost):
		print("Not enough energy!")
		return
	
	for effect in pending_card.effects:
		if effect is MovementEffect:
			effect.apply(target)
	
	print(
		"Played ",
		pending_card.card_name,
		" on ",
		target.name,
	)
	
	selected_character = target
	pending_card = null
	
	_finish_action()


func _handle_card_cell_target(cell : BoardCell) -> void:
	if pending_card == null:
		return
	
	var grid_pos := cell.grid_position
	
	# Make sure the cell is in current player's deployment zone
	if current_player.player_type == PlayerOption.Type.PLAYER_ONE:
		if grid_pos.x > 1:
			return
	else:
		if grid_pos.x < 6:
			return
	
	# Can't deploy onto a base
	if board.is_base_cell(grid_pos):
		return
	
	# Can't deploy onto a character
	if _is_cell_occupied(grid_pos):
		return
	
	if not current_player.spend_energy(pending_card.energy_cost):
		print("Not enough energy!")
		return
	
	for effect in pending_card.effects:
		if effect is DeployCharacterEffect:
			var character_parent := current_player.get_node("Characters")
			
			var new_char : TestCharacter = effect.apply(
				current_player,
				grid_pos,
				board,
				character_parent
			)
			
			new_char.clicked.connect(_on_character_clicked)
	
	print("Played ", pending_card.card_name, " at ", grid_pos)
	
	pending_card = null
	current_mode = GameMode.NORMAL_SELECTION
	_clear_target_highlights()
	board.clear_highlights()


# ======================================================
# BASE SELECTION
# ======================================================

func _on_base_clicked(clicked_base : Base) -> void:
	if game_over:
		return
	
	# Teleport doesn't target bases
	# Ignore base clicks while teleport is active
	if current_mode == GameMode.ABILITY_MODE:
		if selected_character != null and selected_character.ability != null:
			if selected_character.ability.ability_type == AbilityData.AbilityType.TELEPORT:
				return
	
	# Ability targeting
	if current_mode == GameMode.ABILITY_MODE and selected_character != null:
		if clicked_base.owner_player != selected_character.owner_player:
			if _try_use_ability_on_base(clicked_base):
				return
	
	# Normal attack targeting
	if current_mode == GameMode.ATTACK_MODE and selected_character != null:
		if clicked_base.owner_player != selected_character.owner_player:
			if _try_attack_base(clicked_base):
				return
		
		# Clicking your own base exits attack mode
		_cancel_current_mode()


# ======================================================
# BOARD CELL INPUT
# ======================================================

func _on_cell_clicked(cell : BoardCell) -> void:
	if game_over:
		return
	
	if current_mode == GameMode.CARD_TARGET_MODE:
		if pending_card == null:
			return
		
		_handle_card_cell_target(cell)
		return
	
	if selected_character == null:
		return
	
	if selected_character.owner_player != TurnManager.current_player:
		return
	
	match current_mode:
		GameMode.MOVEMENT_MODE:
			_handle_movement(cell)
		
		GameMode.ATTACK_MODE:
			_handle_attack(cell)
		
		GameMode.ABILITY_MODE:
			_handle_ability(cell)
		
		GameMode.NORMAL_SELECTION:
			pass


# ===============================================
# MOVEMENT
# ===============================================

func _handle_movement(cell : BoardCell) -> void:
	if selected_character == null:
		return
	
	if not selected_character.movement_available:
		return
	
	if cell.grid_position == selected_character.grid_position:
		return
	
	# Cannot move onto a base cell
	if board.is_base_cell(cell.grid_position):
		return
	
	# Check movement range
	if _distance_between(
		selected_character.grid_position,
		cell.grid_position
	) > selected_character.movement:
		return
	
	# Check if another character occupies the destination
	if _get_character_at(cell.grid_position) != null:
		return
	
	board.move_character(
		selected_character,
		cell.grid_position
	)
	
	_finish_action()


# =======================================================
# ATTACKING
# =======================================================

func _handle_attack(cell : BoardCell) -> void:
	if selected_character == null:
		return
	
	if not selected_character.attack_available:
		return
	
	if cell.grid_position == selected_character.grid_position:
		return
	
	if _distance_between(
		selected_character.grid_position,
		cell.grid_position
	) > selected_character.attack_range:
		return
	
	# Base target
	if board.is_base_cell(cell.grid_position):
		var target_base : Base = board.base_cells.get(cell.grid_position)
		
		if target_base.owner_player == selected_character.owner_player:
			return
		
		_try_attack_base(target_base)
		return
	
	# Character target
	var target_character := _get_character_at(cell.grid_position)
	
	if target_character == null:
		return
	
	if target_character.owner_player == selected_character.owner_player:
		return
	
	_try_attack_character(target_character)


func _try_attack_character(target : TestCharacter) -> bool:
	if selected_character == null:
		return false
	
	if not selected_character.attack_available:
		return false
	
	if target.owner_player == selected_character.owner_player:
		return false
	
	if _distance_between(
		selected_character.grid_position,
		target.grid_position
	) > selected_character.attack_range:
		return false
	
	print("Attacking ", target.grid_position, " for ", selected_character.attack_damage, " damage")
	
	target.take_damage(selected_character.attack_damage)
	
	print("Target health: ", target.current_health)
	
	selected_character.attack_available = false
	
	if target.current_health <= 0:
		print("Target defeated!")
		_remove_character(target)
	
	_finish_action()
	
	return true


func _try_attack_base(target_base : Base) -> bool:
	if selected_character == null:
		return false
	
	if not selected_character.attack_available:
		return false
	
	if target_base.owner_player == selected_character.owner_player:
		return false
	
	if not _base_in_range(
		target_base,
		selected_character.attack_range
	):
		return false
	
	print("Attacking ", target_base.name, " for ", selected_character.attack_damage, " damage")
	
	target_base.take_damage(selected_character.attack_damage)
	
	print("Base health: ", target_base.current_health)
	
	selected_character.attack_available = false
	
	if target_base.current_health <= 0:
		_on_base_destroyed(target_base)
	
	_finish_action()
	
	return true


# ========================================================
# ABILITIES
# ========================================================

func _handle_ability(cell : BoardCell) -> void:
	if selected_character == null:
		return
	
	if not selected_character.ability_available:
		return
	
	if selected_character.ability == null:
		return
	
	# Teleport is handled seperately, it targets empty board cell instead on an enemy
	if selected_character.ability.ability_type == AbilityData.AbilityType.TELEPORT:
		_handle_teleport(cell)
		return
	
	if cell.grid_position == selected_character.grid_position:
		return
	
	if _distance_between(
		selected_character.grid_position,
		cell.grid_position
	) > selected_character.ability.ability_range:
		return
	
	# Base target
	if board.is_base_cell(cell.grid_position):
		var target_base : Base = board.base_cells.get(cell.grid_position)
		
		if target_base.owner_player == selected_character.owner_player:
			return
		
		_try_use_ability_on_base(target_base)
		return
	
	# Character target
	var target_character := _get_character_at(cell.grid_position)
	
	if target_character == null:
		return
	
	if target_character.owner_player == selected_character.owner_player:
		return
	
	_try_use_ability_on_character(target_character)


func _try_use_ability_on_character(target : TestCharacter) -> bool:
	if selected_character == null:
		return false
	
	if selected_character.ability == null:
		return false
	
	if not selected_character.ability_available:
		return false
	
	if target.owner_player == selected_character.owner_player:
		return false
	
	if _distance_between(
		selected_character.grid_position,
		target.grid_position
	) > selected_character.ability.ability_range:
		return false
	
	# Spend energy only after all validation succeeds
	if not current_player.spend_energy(selected_character.ability.energy_cost):
		print("Not enough energy")
		return false
	
	print(
		"Using ",
		selected_character.ability.ability_name,
		" on ",
		target.grid_position,
		" for ",
		selected_character.ability.damage,
		" damage"
	)
	
	target.take_damage(selected_character.ability.damage)
	
	print("Target health: ", target.current_health)
	
	selected_character.ability_available = false
	
	if target.current_health <= 0:
		print("Target defeated!")
		_remove_character(target)
	
	_finish_action()
	
	return true


func _try_use_ability_on_base(target_base : Base) -> bool:
	if selected_character == null:
		return false
	
	if selected_character.ability == null:
		return false
	
	if not selected_character.ability_available:
		return false
	
	if target_base.owner_player == selected_character.owner_player:
		return false
	
	if not _base_in_range(
		target_base,
		selected_character.ability.ability_range
	):
		return false
	
	# Spend energy only after all validation succeeds
	if not current_player.spend_energy(
		selected_character.ability.energy_cost
	):
		print("Not enough energy!")
		return false
	
	print(
		"Using ",
		selected_character.ability.ability_name,
		" on ",
		target_base.name,
		" for ",
		selected_character.ability.damage,
		" damage"
	)
	
	target_base.take_damage(selected_character.ability.damage)
	
	print("Base health: ", target_base.current_health)
	
	selected_character.ability_available = false
	
	if target_base.current_health <= 0:
		_on_base_destroyed(target_base)
	
	_finish_action()
	
	return true


func _handle_teleport(cell : BoardCell) -> void:
	if selected_character == null:
		return
	
	if selected_character.ability == null:
		return
	
	if not selected_character.ability_available:
		return
	
	# Can't teleport onto current position
	if cell.grid_position == selected_character.grid_position:
		return
	
	# Can't teleport onto a base
	if board.is_base_cell(cell.grid_position):
		return
	
	# Can't teleport onto another character
	if _get_character_at(cell.grid_position) != null:
		return
	
	# Check teleport range
	if _distance_between(
		selected_character.grid_position,
		cell.grid_position
	) > selected_character.ability.ability_range:
		return
	
	# Spend energy only after all validation succeeds
	if not current_player.spend_energy(selected_character.ability.energy_cost):
		print("Not enough energy!")
		return
	
	print("Teleporting ", selected_character.name, " to ", cell.grid_position)
	
	selected_character.set_grid_position(cell.grid_position, board)
	
	selected_character.ability_available = false
	
	_finish_action()


func _show_teleport_range() -> void:
	var occupied_positions: Array[Vector2i] = []
	
	for player in [player_one, player_two]:
		for _character in player.characters:
			occupied_positions.append(_character.grid_position)
	
	var teleport_cells := board.get_cells_in_range(
		selected_character.grid_position,
		selected_character.ability.ability_range
	)
	
	board.clear_highlights()
	
	for cell in teleport_cells:
		if cell.grid_position == selected_character.grid_position:
			continue
		
		if board.is_base_cell(cell.grid_position):
			continue
		
		if cell.grid_position in occupied_positions:
			continue
		
		cell.highlight_ability()
		board.highlighted_cells.append(cell)


# ===================================================
# UI BUTTONS / MODES
# ===================================================

func _on_move_button_pressed() -> void:
	if game_over:
		return
	
	if selected_character == null:
		return
	
	if not selected_character.movement_available:
		return
	
	current_mode = GameMode.MOVEMENT_MODE
	
	_clear_target_highlights()
	
	var occupied_positions : Array[Vector2i] = []
	var enemy_positions : Array[Vector2i] = []
	
	for player in [player_one, player_two]:
		for _character in player.characters:
			occupied_positions.append(_character.grid_position)
			
			if _character.owner_player != selected_character.owner_player:
				enemy_positions.append(_character.grid_position)
	
	board.show_movement_range(
		selected_character,
		occupied_positions,
		enemy_positions
	)


func _on_attack_button_pressed() -> void:
	if game_over:
		return
	
	if selected_character == null:
		return
	
	if not selected_character.attack_available:
		return
	
	current_mode = GameMode.ATTACK_MODE
	
	_clear_target_highlights()
	
	var enemy_positions : Array[Vector2i] = []
	
	for player in [player_one, player_two]:
		for _character in player.characters:
			if _character.owner_player != selected_character.owner_player:
				enemy_positions.append(_character.grid_position)
				
				if _distance_between(
					selected_character.grid_position,
					_character.grid_position
				) <= selected_character.attack_range:
					_character.highlight_as_target()
					highlighted_targets.append(_character)
	
	# Find enemy base
	var enemy_base := _get_enemy_base()
	
	var base_cells := board.get_base_cells(enemy_base)
	
	if _base_in_range(enemy_base, selected_character.attack_range):
		enemy_base.highlight_as_target()
		highlighted_bases.append(enemy_base)
	
	for base_cell in base_cells:
		enemy_positions.append(base_cell)
	
	board.show_attack_range(
		selected_character,
		enemy_positions
	)


func _on_ability_button_pressed() -> void:
	if game_over:
		return
	
	if selected_character == null:
		return
	
	if not selected_character.ability_available:
		return
	
	if selected_character.ability == null:
		return
		
	current_mode = GameMode.ABILITY_MODE
	
	_clear_target_highlights()
	
	# Teleport has different targeting behavior
	if selected_character.ability.ability_type == AbilityData.AbilityType.TELEPORT:
		_show_teleport_range()
		return
	
	# Damage Ability targeting
	var enemy_positions : Array[Vector2i] = []
	
	for player in [player_one, player_two]:
		for _character in player.characters:
			if _character.owner_player != selected_character.owner_player:
				enemy_positions.append(_character.grid_position)
				
				if _distance_between(
					selected_character.grid_position,
					_character.grid_position
				) <= selected_character.ability.ability_range:
					_character.highlight_as_target()
					highlighted_targets.append(_character)
	
	# Find enemy base
	var enemy_base := _get_enemy_base()
	
	var base_cells := board.get_base_cells(enemy_base)
	
	if _base_in_range(
		enemy_base,
		selected_character.ability.ability_range
	):
		enemy_base.highlight_as_target()
		highlighted_bases.append(enemy_base)
		
	for base_cell in base_cells:
		enemy_positions.append(base_cell)
	
	board.show_ability_range(
		selected_character,
		enemy_positions
	)


# ======================================================
# HELPERS
# ======================================================

func _distance_between(a: Vector2i, b : Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)


func _is_cell_occupied(grid_pos : Vector2i) -> bool:
	for player in [player_one, player_two]:
		for _char in player.characters:
			if _char.grid_position == grid_pos:
				return true
	
	return false


func _get_character_at(grid_position : Vector2i) -> TestCharacter:
	for player in [player_one, player_two]:
		for _character in player.characters:
			if _character.grid_position == grid_position:
				return _character
	
	return null


func _get_enemy_base() -> Base:
	if selected_character.owner_player == PlayerOption.Type.PLAYER_ONE:
		return player_two_base
	
	return player_one_base


func _base_in_range(target_base : Base, attack_range : int) -> bool:
	for base_cell in board.get_base_cells(target_base):
		if _distance_between(
			selected_character.grid_position,
			base_cell
		) <= attack_range:
			return true
	
	return false


func _clear_target_highlights() -> void:
	for enemy in highlighted_targets:
		enemy.unhighlight_target()
	
	highlighted_targets.clear()
	
	for base in highlighted_bases:
		base.unhighlight_target()
	
	highlighted_bases.clear()


func _cancel_current_mode() -> void:
	board.clear_highlights()
	_clear_target_highlights()
	current_mode = GameMode.NORMAL_SELECTION


func _finish_action() -> void:
	board.clear_highlights()
	_clear_target_highlights()
	
	ui.update_button_states(selected_character)
	
	current_mode = GameMode.NORMAL_SELECTION


# ==================================================
# CHARACTER / BASE MANAGEMENT
# ==================================================

func _remove_character(target : TestCharacter) -> void:
	if target.owner_player == PlayerOption.Type.PLAYER_ONE:
		player_one.characters.erase(target)
	else:
		player_two.characters.erase(target)
	
	if target in highlighted_targets:
		highlighted_targets.erase(target)
	
	target.queue_free()


func _on_base_destroyed(base : Base) -> void:
	if game_over:
		return
	
	game_over = true
	current_mode = GameMode.NORMAL_SELECTION
	
	board.clear_highlights()
	_clear_target_highlights()
	
	ui.hide_character_panel()
	
	var winner : String
	
	if base.owner_player == PlayerOption.Type.PLAYER_ONE:
		winner = "Player 2"
	else:
		winner = "Player 1"
	
	print("Game Over! ", winner, " wins!")
