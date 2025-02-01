extends TileMapLayer

func _ready():
	SignalBus.connect("highlightTiles", _highlightTiles)
	SignalBus.connect("clearHighlights", _clearHighlights)

func _highlightTiles(tiles: PackedVector2Array):
	for tile in tiles:
		set_cell(tile, 0, Vector2i(0,0))

func _clearHighlights():
	clear()
