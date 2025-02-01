extends Node

const PieceEnum = preload("res://piece_enum.gd")
const PieceTeam = PieceEnum.PieceTeam

signal highlightTiles(tiles: PackedVector2Array)

signal clearHighlights

signal move_piece(old_hex: Vector2i, new_hex: Vector2i, piece_team: PieceTeam)
