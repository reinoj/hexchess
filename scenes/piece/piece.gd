extends Node2D
class_name Piece

const PieceType = PieceEnum.PieceType
const PieceTeam = PieceEnum.PieceTeam

const SIZE: int = 64
const PIECE_SIZE: int = 82
const TEAM_COLORS = {
	PieceTeam.BLACK: Color(0.40, 0.40, 0.40),
	PieceTeam.WHITE: Color(0.90, 0.90, 0.90)
}

var dragging: bool
# oddq
var location: Vector2i
var piece_type: PieceType
var piece_team: PieceTeam
# oddq
var move_locations: Array[Vector2i]

@onready var game_node: Node2D = $"../"
@onready var sprite: Sprite2D = $"Sprite2D"
@onready var tile_map: TileMapLayer = $"../Board"
@onready var DROP_OFFSET = tile_map.transform.get_origin()

func _ready():
	dragging = false

func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position()

func initialize_piece(_piece_type: PieceType, _piece_team: PieceTeam):
	piece_team = _piece_team
	set_piece_type(_piece_type)
	sprite.modulate = TEAM_COLORS[piece_team]

func set_piece_type(_piece_type: PieceType):
	piece_type = _piece_type
	sprite.region_rect = Rect2(PieceEnum.PieceAtlas[piece_type], 0, PIECE_SIZE, PIECE_SIZE)

func set_piece_position(hex: Vector2i):
	global_position = tile_map.map_to_local(hex) + DROP_OFFSET
	location = hex

func _on_area_2d_input_event(_viewport, event: InputEvent, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			if Globals.turn == piece_team:
				dragging = true
				z_index = 1
				move_locations.append(location)
				get_piece_move_options()
				SignalBus.highlightTiles.emit(move_locations)
		elif event.is_released():
			if Globals.turn == piece_team:
				dragging = false
				z_index = 0
				var new_pos: Vector2i = tile_map.local_to_map(get_global_mouse_position() - DROP_OFFSET)
				if move_locations.has(new_pos):
					if location != new_pos:
						SignalBus.move_piece.emit(HexFunctions.oddq_to_axial(location), HexFunctions.oddq_to_axial(new_pos), piece_team)
						if piece_type == PieceType.PAWN:
							pawn_upgrade_check(new_pos)
						#is_king_in_check()
						Globals.turn = PieceEnum.other_team(piece_team)
					set_piece_position(tile_map.local_to_map(get_global_mouse_position() - DROP_OFFSET))
				else:
					set_piece_position(location)
				move_locations.clear()
				SignalBus.clearHighlights.emit()

const LONGEST_ROOK_MOVE: int = 10
const LONGEST_BISHOP_MOVE: int = 5
func get_piece_move_options():
	# axial
	var axial_location = HexFunctions.oddq_to_axial(location)
	match piece_type:
		PieceType.PAWN:
			get_pawn_moves(axial_location)
		PieceType.ROOK:
			get_rook_moves(axial_location, LONGEST_ROOK_MOVE)
		PieceType.KNIGHT:
			get_knight_moves(axial_location)
		PieceType.BISHOP:
			get_bishop_moves(axial_location, LONGEST_BISHOP_MOVE)
		PieceType.QUEEN:
			get_rook_moves(axial_location, LONGEST_ROOK_MOVE)
			get_bishop_moves(axial_location, LONGEST_BISHOP_MOVE)
		PieceType.KING:
			get_rook_moves(axial_location, 1)
			get_bishop_moves(axial_location, 1)

func get_pawn_moves(hex: Vector2i):
	# move 1 forward
	var move_one: bool = false
	var test_hex: Vector2i = pawn_next_hex(hex)
	if test_pawn_move_hex(test_hex):
		move_locations.append(HexFunctions.axial_to_oddq(test_hex))
		move_one = true
	# move 2 forward if in a start location
	if move_one and hex in Globals.pawn_starts[piece_team]:
		test_hex = pawn_next_hex(test_hex)
		if test_pawn_move_hex(test_hex):
			move_locations.append(HexFunctions.axial_to_oddq(test_hex))
	# side captures
	if piece_team == PieceTeam.WHITE:
		test_hex = Vector2i(hex.x-1, hex.y)
	else:
		test_hex = Vector2i(hex.x-1, hex.y+1)
	pawn_side_captures(test_hex)

# axial -> axial
func pawn_next_hex(hex: Vector2i) -> Vector2i:
	if piece_team == PieceTeam.WHITE:
		return Vector2i(hex.x, hex.y - 1)
	else:
		return Vector2i(hex.x, hex.y + 1)

# axial
func pawn_side_captures(hex: Vector2i):
	if Globals.locations[PieceEnum.other_team(piece_team)].has(hex):
		move_locations.append(HexFunctions.axial_to_oddq(hex))
	hex.x += 2
	hex.y -= 1
	if Globals.locations[PieceEnum.other_team(piece_team)].has(hex):
		move_locations.append(HexFunctions.axial_to_oddq(hex))

# oddq
func pawn_upgrade_check(hex: Vector2i):
	if Globals.pawn_upgrades[piece_team].has(HexFunctions.oddq_to_axial(hex)):
		set_piece_type(PieceType.QUEEN)

# axial
func get_rook_moves(hex: Vector2i, longest_move: int):
	# q-axis
	var test_hex: Vector2i = Vector2i(hex.x, hex.y+1)
	for i in range(longest_move):
		var test_res: Array[bool] = test_move_hex(test_hex)
		if test_res[0]:
			move_locations.append(HexFunctions.axial_to_oddq(test_hex))
			test_hex.y += 1
			if test_res[1]:
				break
		else:
			break
	test_hex = Vector2i(hex.x, hex.y-1)
	for i in range(longest_move):
		var test_res: Array[bool] = test_move_hex(test_hex)
		if test_res[0]:
			move_locations.append(HexFunctions.axial_to_oddq(test_hex))
			test_hex.y -= 1
			if test_res[1]:
				break
		else:
			break
	# r-axis
	test_hex = Vector2i(hex.x+1, hex.y)
	for i in range(longest_move):
		var test_res: Array[bool] = test_move_hex(test_hex)
		if test_res[0]:
			move_locations.append(HexFunctions.axial_to_oddq(test_hex))
			test_hex.x += 1
			if test_res[1]:
				break
		else:
			break
	test_hex = Vector2i(hex.x-1, hex.y)
	for i in range(longest_move):
		var test_res: Array[bool] = test_move_hex(test_hex)
		if test_res[0]:
			move_locations.append(HexFunctions.axial_to_oddq(test_hex))
			test_hex.x -= 1
			if test_res[1]:
				break
		else:
			break
	# s-axis
	test_hex = Vector2i(hex.x+1, hex.y-1)
	for i in range(longest_move):
		var test_res: Array[bool] = test_move_hex(test_hex)
		if test_res[0]:
			move_locations.append(HexFunctions.axial_to_oddq(test_hex))
			test_hex.x += 1
			test_hex.y -= 1
			if test_res[1]:
				break
		else:
			break
	test_hex = Vector2i(hex.x-1, hex.y+1)
	for i in range(longest_move):
		var test_res: Array[bool] = test_move_hex(test_hex)
		if test_res[0]:
			move_locations.append(HexFunctions.axial_to_oddq(test_hex))
			test_hex.x -= 1
			test_hex.y += 1
			if test_res[1]:
				break
		else:
			break

# axial
func get_knight_moves(hex: Vector2i):
	# q+
	var test_hex: Vector2i = Vector2i(hex.x+3, hex.y-1)
	if test_move_hex(test_hex)[0]:
		move_locations.append(HexFunctions.axial_to_oddq(test_hex))
	test_hex.y -= 1
	if test_move_hex(test_hex)[0]:
		move_locations.append(HexFunctions.axial_to_oddq(test_hex))
	
	# r-
	test_hex.x -= 1
	test_hex.y -= 1
	if test_move_hex(test_hex)[0]:
		move_locations.append(HexFunctions.axial_to_oddq(test_hex))
	test_hex.x -= 1
	if test_move_hex(test_hex)[0]:
		move_locations.append(HexFunctions.axial_to_oddq(test_hex))
	
	# s+
	test_hex.x -= 2
	test_hex.y += 1
	if test_move_hex(test_hex)[0]:
		move_locations.append(HexFunctions.axial_to_oddq(test_hex))
	test_hex.x -= 1
	test_hex.y += 1
	if test_move_hex(test_hex)[0]:
		move_locations.append(HexFunctions.axial_to_oddq(test_hex))
	
	# q-
	test_hex.x -= 1
	test_hex.y += 2
	if test_move_hex(test_hex)[0]:
		move_locations.append(HexFunctions.axial_to_oddq(test_hex))
	test_hex.y += 1
	if test_move_hex(test_hex)[0]:
		move_locations.append(HexFunctions.axial_to_oddq(test_hex))
	
	# r+
	test_hex.x += 1
	test_hex.y += 1
	if test_move_hex(test_hex)[0]:
		move_locations.append(HexFunctions.axial_to_oddq(test_hex))
	test_hex.x += 1
	if test_move_hex(test_hex)[0]:
		move_locations.append(HexFunctions.axial_to_oddq(test_hex))
	
	# s-
	test_hex.x += 2
	test_hex.y -= 1
	if test_move_hex(test_hex)[0]:
		move_locations.append(HexFunctions.axial_to_oddq(test_hex))
	test_hex.x += 1
	test_hex.y -= 1
	if test_move_hex(test_hex)[0]:
		move_locations.append(HexFunctions.axial_to_oddq(test_hex))

# axial
func get_bishop_moves(hex: Vector2i, longest_move: int):
	# q+
	var test_hex: Vector2i = Vector2i(hex.x+2, hex.y-1)
	for i in range(longest_move):
		var test_res: Array[bool] = test_move_hex(test_hex)
		if test_res[0]:
			move_locations.append(HexFunctions.axial_to_oddq(test_hex))
			test_hex.x += 2
			test_hex.y -= 1
			if test_res[1]:
				break
		else:
			break
	# q-
	test_hex = Vector2i(hex.x-2, hex.y+1)
	for i in range(longest_move):
		var test_res: Array[bool] = test_move_hex(test_hex)
		if test_res[0]:
			move_locations.append(HexFunctions.axial_to_oddq(test_hex))
			test_hex.x -= 2
			test_hex.y += 1
			if test_res[1]:
				break
		else:
			break
	# r+
	test_hex = Vector2i(hex.x-1, hex.y+2)
	for i in range(longest_move):
		var test_res: Array[bool] = test_move_hex(test_hex)
		if test_res[0]:
			move_locations.append(HexFunctions.axial_to_oddq(test_hex))
			test_hex.x -= 1
			test_hex.y += 2
			if test_res[1]:
				break
		else:
			break
	# r-
	test_hex = Vector2i(hex.x+1, hex.y-2)
	for i in range(longest_move):
		var test_res: Array[bool] = test_move_hex(test_hex)
		if test_res[0]:
			move_locations.append(HexFunctions.axial_to_oddq(test_hex))
			test_hex.x += 1
			test_hex.y -= 2
			if test_res[1]:
				break
		else:
			break
	# s+
	test_hex = Vector2i(hex.x-1, hex.y-1)
	for i in range(longest_move):
		var test_res: Array[bool] = test_move_hex(test_hex)
		if test_res[0]:
			move_locations.append(HexFunctions.axial_to_oddq(test_hex))
			test_hex.x -= 1
			test_hex.y -= 1
			if test_res[1]:
				break
		else:
			break
	# s-
	test_hex = Vector2i(hex.x+1, hex.y+1)
	for i in range(longest_move):
		var test_res: Array[bool] = test_move_hex(test_hex)
		if test_res[0]:
			move_locations.append(HexFunctions.axial_to_oddq(test_hex))
			test_hex.x += 1
			test_hex.y += 1
			if test_res[1]:
				break
		else:
			break

# true -> can move here
# axial
func test_pawn_move_hex(hex: Vector2i) -> bool:
	return !Globals.locations[PieceTeam.BLACK].has(hex) and \
		!Globals.locations[PieceTeam.WHITE].has(hex) and \
		tile_map.get_cell_tile_data(HexFunctions.axial_to_oddq(hex)) != null

# [true -> can move here, true -> enemy piece at location]
# axial
func test_move_hex(hex: Vector2i) -> Array[bool]:
	return [!Globals.locations[piece_team].has(hex) and \
		tile_map.get_cell_tile_data(HexFunctions.axial_to_oddq(hex)) != null,
		Globals.locations[PieceEnum.other_team(piece_team)].has(hex)]

# TODO
# iterate over current team's pieces and see if any of them can capture the enemy king
# if so -> check 
# then if the king can:
# 	- can move to a non-attacked hex
# 		- recheck current team pieces in case this involves capturing a piece
# 	- a friendly piece can get in the way
# 		- check all possible friendly moves and if one blocks it's not checkmate
# 	- else checkmate
#func is_king_in_check():
	#pass
