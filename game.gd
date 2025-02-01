extends Node2D

var piece_scene: PackedScene = preload("res://piece.tscn")

const PieceEnum = preload("res://piece_enum.gd")
const PieceType = PieceEnum.PieceType
const PieceTeam = PieceEnum.PieceTeam

const HexFunctions = preload("res://hex_functions.gd")

# axial
# 0: black, 1: white
const pawn_starts: Array = [
	[Vector2i(1,2), Vector2i(2,2), Vector2i(3,2), Vector2i(4,2), Vector2i(5,2), Vector2i(6,1), Vector2i(7,0), Vector2i(8,-1), Vector2i(9,-2)],
	[Vector2i(1,8), Vector2i(2,7), Vector2i(3,6), Vector2i(4,5), Vector2i(5,4), Vector2i(6,4), Vector2i(7,4), Vector2i(8,4), Vector2i(9,4)]
]

# axial
# using these dicts as sets, value will always be set to null
var locations: Array = [{}, {}]

func _ready():
	load_pieces()
	SignalBus.connect("move_piece", _move_piece)

func load_pieces():
	# formation based on Glinski
	# axial coordinates for the Vectors in this functions
	
	# Pawns
	var cur_piece_type = PieceType.PAWN
	for hex_b in pawn_starts[PieceTeam.BLACK]:
		spawn_piece(hex_b, cur_piece_type, PieceTeam.BLACK)
	for hex_w in pawn_starts[PieceTeam.WHITE]:
		spawn_piece(hex_w, cur_piece_type, PieceTeam.WHITE)
	
	# Rooks
	var hex_b = Vector2i(2, 1)
	var hex_w = Vector2i(2, 8)
	cur_piece_type = PieceType.ROOK
	for i in range(2):
		spawn_piece(hex_b, cur_piece_type, PieceTeam.BLACK)
		spawn_piece(hex_w, cur_piece_type, PieceTeam.WHITE)
		hex_b.x += 6
		hex_b.y -= 3
		hex_w.x += 6
		hex_w.y -= 3
	
	# Knights
	hex_b = Vector2i(3, 0)
	hex_w = Vector2i(3, 8)
	cur_piece_type = PieceType.KNIGHT
	for i in range(2):
		spawn_piece(hex_b, cur_piece_type, PieceTeam.BLACK)
		spawn_piece(hex_w, cur_piece_type, PieceTeam.WHITE)
		hex_b.x += 4
		hex_b.y -= 2
		hex_w.x += 4
		hex_w.y -= 2
	
	# Bishops
	hex_b = Vector2i(5, -2)
	hex_w = Vector2i(5, 8)
	cur_piece_type = PieceType.BISHOP
	for i in range(3):
		spawn_piece(hex_b, cur_piece_type, PieceTeam.BLACK)
		spawn_piece(hex_w, cur_piece_type, PieceTeam.WHITE)
		hex_b.y += 1
		hex_w.y -= 1
	
	# Queens
	hex_b = Vector2i(4, -1)
	hex_w = Vector2i(4, 8)
	cur_piece_type = PieceType.QUEEN
	spawn_piece(hex_b, cur_piece_type, PieceTeam.BLACK)
	spawn_piece(hex_w, cur_piece_type, PieceTeam.WHITE)
	
	# Kings
	hex_b = Vector2i(6, -2)
	hex_w = Vector2i(6, 7)
	cur_piece_type = PieceType.KING
	spawn_piece(hex_b, cur_piece_type, PieceTeam.BLACK)
	spawn_piece(hex_w, cur_piece_type, PieceTeam.WHITE)

func spawn_piece(hex: Vector2i, piece_type: PieceType, piece_team: PieceTeam):
	var piece: Node2D = piece_scene.instantiate()
	add_child(piece)
	piece.set_piece_position(HexFunctions.axial_to_oddq(hex))
	piece.initialize_piece(piece_type, piece_team)
	match piece_team:
		PieceTeam.BLACK:
			locations[PieceTeam.BLACK][hex] = null
		PieceTeam.WHITE:
			locations[PieceTeam.WHITE][hex] = null

func _move_piece(old_hex: Vector2i, new_hex: Vector2i, piece_team: PieceTeam):
	locations[piece_team].erase(old_hex)
	locations[piece_team][new_hex] = null
