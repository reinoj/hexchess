extends TileMapLayer

func _ready():
	SignalBus.connect("highlightTiles", _highlightTiles)
	SignalBus.connect("clearHighlights", _clearHighlights)

func _highlightTiles(tiles: PackedVector2Array):
	set_cell(tiles[0], 0, Vector2i(0,0))
	for tile in tiles.slice(1, tiles.size()):
		set_cell(tile, 1, Vector2i(0,0))

func _clearHighlights():
	clear()
