extends Node

const PieceTeam = PieceEnum.PieceTeam

# axial
# using these dicts as sets, value will always be set to null
var locations: Array[Dictionary] = [{}, {}]

# axial
# 0: black, 1: white
const pawn_starts: Array = [
	[Vector2i(1,2), Vector2i(2,2), Vector2i(3,2), Vector2i(4,2), Vector2i(5,2), Vector2i(6,1), Vector2i(7,0), Vector2i(8,-1), Vector2i(9,-2)],
	[Vector2i(1,8), Vector2i(2,7), Vector2i(3,6), Vector2i(4,5), Vector2i(5,4), Vector2i(6,4), Vector2i(7,4), Vector2i(8,4), Vector2i(9,4)]
]

# axial
# 0: black upgrade locations (white side), 1: white upgrade locations (black side)
const pawn_upgrades: Array = [
	[Vector2i(0,8), Vector2i(1,8), Vector2i(2,8), Vector2i(3,8), Vector2i(4,8), Vector2i(5,8), Vector2i(6,7), Vector2i(7,6), Vector2i(8,5), Vector2i(9,4), Vector2i(10,3)],
	[Vector2i(0,3), Vector2i(1,2), Vector2i(2,1), Vector2i(3,0), Vector2i(4,-1), Vector2i(5, -2), Vector2i(6, -2), Vector2i(7,-2), Vector2i(8,-2), Vector2i(9,-2), Vector2i(10, -2)]
]

var turn: PieceTeam = PieceTeam.WHITE
