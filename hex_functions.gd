extends Node

func axial_to_oddq(hex: Vector2i) -> Vector2i:
	@warning_ignore("integer_division")
	var y: int = hex.y + (hex.x - (hex.x & 1)) / 2
	return Vector2i(hex.x, y)

func oddq_to_axial(hex: Vector2i) -> Vector2i:
	@warning_ignore("integer_division")
	var y = hex.y - (hex.x - (hex.x & 1)) / 2
	return Vector2i(hex.x, y)

# TODO
func is_on_board(hex: Vector2i) -> bool:
	return false
