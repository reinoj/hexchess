extends Node2D

const PieceEnum = preload("res://piece_enum.gd")
const PieceType = PieceEnum.PieceType
const PieceTeam = PieceEnum.PieceTeam

const SIZE: int = 64
const PIECE_SIZE: int = 82
const TEAM_COLORS = {
	PieceTeam.BLACK: Color(0.75, 0.10, 0.25),
	PieceTeam.WHITE: Color(0.20, 0.25, 0.65)
}

var dragging: bool
var location: Vector2i
var piece_type: PieceType
var pa: PackedVector2Array

@onready var game_node: Node2D = $"../../Node"
@onready var sprite: Sprite2D = $"Sprite2D"
@onready var tile_map: TileMapLayer = $"../Board"
@onready var DROP_OFFSET = tile_map.transform.get_origin()

func _ready():
	dragging = false

func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position()

func initialize_piece(_piece_type: PieceType, _piece_team: PieceTeam):
	piece_type = _piece_type
	sprite.region_rect = Rect2(PieceEnum.PieceAtlas[piece_type], 0, PIECE_SIZE, PIECE_SIZE)
	sprite.modulate = TEAM_COLORS[_piece_team]

func set_piece_position(hex: Vector2i):
	global_position = tile_map.map_to_local(hex) + DROP_OFFSET
	location = tile_map.local_to_map(global_position)

func _on_area_2d_input_event(_viewport, event: InputEvent, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			dragging = true
			z_index = 1
			pa.append(location)
			SignalBus.highlightTiles.emit(pa)
		elif event.is_released():
			dragging = false
			z_index = 0
			pa.clear()
			set_piece_position(tile_map.local_to_map(get_global_mouse_position() - DROP_OFFSET))
			SignalBus.clearHighlights.emit()
