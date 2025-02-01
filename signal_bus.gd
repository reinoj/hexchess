extends Node

const PieceTeam = PieceEnum.PieceTeam

@warning_ignore("unused_signal")
signal highlightTiles(tiles: PackedVector2Array)

@warning_ignore("unused_signal")
signal clearHighlights

@warning_ignore("unused_signal")
signal move_piece(old_hex: Vector2i, new_hex: Vector2i, piece_team: PieceTeam)
