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
var move_locations: PackedVector2Array

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
	location = tile_map.local_to_map(global_position)

func _on_area_2d_input_event(_viewport, event: InputEvent, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			dragging = true
			z_index = 1
			move_locations.append(location)
			move_locations.append_array(get_piece_move_options())
			SignalBus.highlightTiles.emit(move_locations)
		elif event.is_released():
			dragging = false
			z_index = 0
			move_locations.clear()
			var new_pos = tile_map.local_to_map(get_global_mouse_position() - DROP_OFFSET)
			# check if `new_pos` is in `move_locations`, if not -> set piece at `location`, if so -> do the check and set below
			# do check to make sure new_pos is on the board
			if location != new_pos:
				SignalBus.move_piece.emit(HexFunctions.oddq_to_axial(location), HexFunctions.oddq_to_axial(new_pos), piece_team)
			set_piece_position(tile_map.local_to_map(get_global_mouse_position() - DROP_OFFSET))
			SignalBus.clearHighlights.emit()

func get_piece_move_options() -> PackedVector2Array:
	var pa: PackedVector2Array
	
	#var locations : Array = game_node.get("locations")
	var black_locations: Array = Globals.locations[PieceTeam.BLACK].keys()
	var white_locations: Array = Globals.locations[PieceTeam.WHITE].keys()
	# axial
	var test_hex: Vector2i
	var axial_location = HexFunctions.oddq_to_axial(location)
	match piece_type:
		PieceType.PAWN:
			# move 1 forward
			test_hex = pawn_next_hex(axial_location)
			if test_hex not in black_locations and test_hex not in white_locations:
				pa.append(HexFunctions.axial_to_oddq(test_hex))
			# move 2 forward if in a start location
			if axial_location in Globals.pawn_starts[piece_team]:
				test_hex = pawn_next_hex(test_hex)
				if test_hex not in black_locations and test_hex not in white_locations:
					pa.append(HexFunctions.axial_to_oddq(test_hex))
			# side captures
			if piece_team == PieceTeam.WHITE:
				test_hex = Vector2i(axial_location.x-1, axial_location.y)
				pa.append_array(pawn_side_captures(test_hex, black_locations))
			else:
				test_hex = Vector2i(axial_location.x-1, axial_location.y+1)
				pa.append_array(pawn_side_captures(test_hex, white_locations))
		PieceType.ROOK:
			pass
	return pa

# axial -> axial
func pawn_next_hex(hex: Vector2i) -> Vector2i:
	if piece_team == PieceTeam.WHITE:
		return Vector2i(hex.x, hex.y - 1)
	else:
		return Vector2i(hex.x, hex.y + 1)

# axial -> array<oddq>
func pawn_side_captures(test_hex: Vector2i, opposite_locations: Array) -> PackedVector2Array:
	var pa: PackedVector2Array
	if test_hex in opposite_locations:
		pa.append(HexFunctions.axial_to_oddq(test_hex))
	test_hex.x += 2
	test_hex.y -= 1
	if test_hex in opposite_locations:
		pa.append(HexFunctions.axial_to_oddq(test_hex))
	return pa
