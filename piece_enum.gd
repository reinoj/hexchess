extends Node

enum PieceType {PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING}

const PieceAtlas = {
	PieceType.PAWN: 0,
	PieceType.ROOK: 82,
	PieceType.KNIGHT: 164,
	PieceType.BISHOP: 246,
	PieceType.QUEEN: 328,
	PieceType.KING: 410
}

enum PieceTeam {BLACK, WHITE}

func other_team(piece_team: PieceTeam):
	if piece_team == PieceTeam.BLACK:
		return PieceTeam.WHITE
	return PieceTeam.BLACK
