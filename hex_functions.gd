static func axial_to_oddq(hex: Vector2i) -> Vector2i:
	var y: int = hex.y + (hex.x - (hex.x & 1)) / 2
	return Vector2i(hex.x, y)

static func oddq_to_axial(hex: Vector2i) -> Vector2i:
	var y = hex.y - (hex.x - (hex.x & 1)) / 2
	return Vector2i(hex.x, y)

# TODO
static func is_on_board(hex: Vector2i) -> bool:
	return false
