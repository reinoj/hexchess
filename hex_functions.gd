extends Node

@onready var tile_map: TileMapLayer = $"../Node/Board"

func axial_to_oddq(hex: Vector2i) -> Vector2i:
	@warning_ignore("integer_division")
	var y: int = hex.y + (hex.x - (hex.x & 1)) / 2
	return Vector2i(hex.x, y)

func oddq_to_axial(hex: Vector2i) -> Vector2i:
	@warning_ignore("integer_division")
	var y = hex.y - (hex.x - (hex.x & 1)) / 2
	return Vector2i(hex.x, y)
