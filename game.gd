extends Node2D

var piece_scene: PackedScene = preload("res://piece.tscn")

const PieceEnum = preload("res://piece_enum.gd")

func _ready():
	load_pieces()

func load_pieces():
	var piece: Node2D = piece_scene.instantiate()
	add_child(piece)
	piece.set_piece_position(Vector2i(5,0))
	piece.initialize_piece(PieceEnum.PieceType.QUEEN)
