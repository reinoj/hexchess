extends TileMapLayer

const HexFunctions = preload("res://hex_functions.gd")

var TILE_MAP_ID = 0

func _ready():
	fill_board()

func fill_board():
	clear()
	var r_min = 3
	var r_max = 9
	var atlas_coords: Vector2i
	for q in range(0, 11):
		if q <= 5:
			atlas_coords = Vector2i(q % 3, 0)
		else:
			atlas_coords = Vector2i((5-(q-5)) % 3, 0)
		
		for r in range(r_min, r_max):
			set_cell(HexFunctions.axial_to_oddq(Vector2i(q, r)), TILE_MAP_ID, atlas_coords)
			atlas_coords.x = (atlas_coords.x + 1) % 3
		
		if q < 5:
			r_min -= 1
		else:
			r_max -= 1
