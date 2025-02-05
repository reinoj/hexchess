extends Node2D

var piece_scene: PackedScene = preload("res://piece.tscn")

const PieceType = PieceEnum.PieceType
const PieceTeam = PieceEnum.PieceTeam

func _ready():
	load_pieces()
	SignalBus.connect("move_piece", _move_piece)

func load_pieces():
	# formation based on Glinski
	# axial coordinates for the Vectors in this functions
	
	# Pawns
	var cur_piece_type = PieceType.PAWN
	for hex_b in Globals.pawn_starts[PieceTeam.BLACK]:
		spawn_piece(hex_b, cur_piece_type, PieceTeam.BLACK)
	for hex_w in Globals.pawn_starts[PieceTeam.WHITE]:
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

# axial
func spawn_piece(hex: Vector2i, piece_type: PieceType, piece_team: PieceTeam):
	var piece: Node2D = piece_scene.instantiate()
	add_child(piece)
	piece.set_piece_position(HexFunctions.axial_to_oddq(hex))
	piece.initialize_piece(piece_type, piece_team)
	match piece_team:
		PieceTeam.BLACK:
			Globals.locations[PieceTeam.BLACK][hex] = null
		PieceTeam.WHITE:
			Globals.locations[PieceTeam.WHITE][hex] = null

# axial
func _move_piece(old_hex: Vector2i, new_hex: Vector2i, piece_team: PieceTeam):
	if Globals.locations[PieceEnum.other_team(piece_team)].has(new_hex):
		capture_piece(new_hex, PieceEnum.other_team(piece_team))
	Globals.locations[piece_team].erase(old_hex)
	Globals.locations[piece_team][new_hex] = null

# axial
func capture_piece(hex: Vector2i, piece_team: PieceTeam):
	var oddq_hex: Vector2i = HexFunctions.axial_to_oddq(hex)
	for child in get_children():
		if child is Piece:
			if oddq_hex == child.location:
				if child.piece_type == PieceType.KING:
					# pop up _ wins screen
					print('%s Wins' % Globals.turn)
				child.queue_free()
				Globals.locations[piece_team].erase(hex)
				break

# TODO
# add buttons to game screen for each side to forfeit
# add popup after one team wins, "___" Wins! and new game button
# add boolean game state variable to globals so that pieces can't be moved after game is done
