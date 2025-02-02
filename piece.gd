extends Node2D

const PieceType = PieceEnum.PieceType
const PieceTeam = PieceEnum.PieceTeam

const SIZE: int = 64
const PIECE_SIZE: int = 82
const TEAM_COLORS = {
	PieceTeam.BLACK: Color(0.75, 0.10, 0.25),
	PieceTeam.WHITE: Color(0.20, 0.25, 0.65)
}

var dragging: bool
# oddq
var location: Vector2i
var piece_type: PieceType
var piece_team: PieceTeam
# oddq
var move_locations: Array[Vector2i]

@onready var game_node: Node2D = $"../../Node"
@onready var sprite: Sprite2D = $"Sprite2D"
@onready var tile_map: TileMapLayer = $"../Board"
@onready var DROP_OFFSET = tile_map.transform.get_origin()

func _ready():
	dragging = false

func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position()

func initialize_piece(_piece_type: PieceType, _piece_team: PieceTeam):
	piece_type = _piece_type
	piece_team = _piece_team
	sprite.region_rect = Rect2(PieceEnum.PieceAtlas[piece_type], 0, PIECE_SIZE, PIECE_SIZE)
	sprite.modulate = TEAM_COLORS[piece_team]

func set_piece_position(hex: Vector2i):
	global_position = tile_map.map_to_local(hex) + DROP_OFFSET
	location = hex

func _on_area_2d_input_event(_viewport, event: InputEvent, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			dragging = true
			z_index = 1
			move_locations.append(location)
			get_piece_move_options()
			SignalBus.highlightTiles.emit(move_locations)
		elif event.is_released():
			dragging = false
			z_index = 0
			var new_pos: Vector2i = tile_map.local_to_map(get_global_mouse_position() - DROP_OFFSET)
			if move_locations.has(new_pos):
				if location != new_pos:
					SignalBus.move_piece.emit(HexFunctions.oddq_to_axial(location), HexFunctions.oddq_to_axial(new_pos), piece_team)
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
	if test_move_hex(test_hex):
		move_locations.append(HexFunctions.axial_to_oddq(test_hex))
		move_one = true
	# move 2 forward if in a start location
	if move_one and hex in Globals.pawn_starts[piece_team]:
		test_hex = pawn_next_hex(test_hex)
		if test_move_hex(test_hex):
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
func pawn_side_captures(test_hex: Vector2i):
	if Globals.locations[PieceEnum.other_team(piece_team)].has(test_hex):
		move_locations.append(HexFunctions.axial_to_oddq(test_hex))
	test_hex.x += 2
	test_hex.y -= 1
	if Globals.locations[PieceEnum.other_team(piece_team)].has(test_hex):
		move_locations.append(HexFunctions.axial_to_oddq(test_hex))

# axial
func get_rook_moves(hex: Vector2i, longest_move: int):
	# q-axis
	var test_hex: Vector2i = Vector2i(hex.x, hex.y+1)
	for i in range(longest_move):
		if test_move_hex(test_hex):
			move_locations.append(HexFunctions.axial_to_oddq(test_hex))
			test_hex.y += 1
		else:
			break
	test_hex = Vector2i(hex.x, hex.y-1)
	for i in range(longest_move):
		if test_move_hex(test_hex):
			move_locations.append(HexFunctions.axial_to_oddq(test_hex))
			test_hex.y -= 1
		else:
			break
	# r-axis
	test_hex = Vector2i(hex.x+1, hex.y)
	for i in range(longest_move):
		if test_move_hex(test_hex):
			move_locations.append(HexFunctions.axial_to_oddq(test_hex))
			test_hex.x += 1
		else:
			break
	test_hex = Vector2i(hex.x-1, hex.y)
	for i in range(longest_move):
		if test_move_hex(test_hex):
			move_locations.append(HexFunctions.axial_to_oddq(test_hex))
			test_hex.x -= 1
		else:
			break
	# s-axis
	test_hex = Vector2i(hex.x+1, hex.y-1)
	for i in range(longest_move):
		if test_move_hex(test_hex):
			move_locations.append(HexFunctions.axial_to_oddq(test_hex))
			test_hex.x += 1
			test_hex.y -= 1
		else:
			break
	# negative s
	test_hex = Vector2i(hex.x-1, hex.y+1)
	for i in range(longest_move):
		if test_move_hex(test_hex):
			move_locations.append(HexFunctions.axial_to_oddq(test_hex))
			test_hex.x -= 1
			test_hex.y += 1
		else:
			break

# TODO
func get_knight_moves(hex: Vector2i):
	pass

# TODO
func get_bishop_moves(hex: Vector2i, longest_move: int):
	pass

# true -> can move here
# axial
func test_move_hex(hex: Vector2i) -> bool:
	return !Globals.locations[PieceTeam.BLACK].has(hex) and \
		!Globals.locations[PieceTeam.WHITE].has(hex) and \
		tile_map.get_cell_tile_data(HexFunctions.axial_to_oddq(hex)) != null
