extends Node2D

const PieceEnum = preload("res://piece_enum.gd")

const SIZE: int = 64
const PIECE_SIZE: int = 82

var dragging: bool
var location: Vector2
var piece_type: PieceEnum.PieceType

@onready var game_node: Node2D = $"../../Node"
@onready var tile_map: TileMapLayer = $"../Board"
@onready var sprite: Sprite2D = $"Sprite2D"
@onready var DROP_OFFSET = tile_map.transform.get_origin()

func _ready():
	dragging = false
	location = get_global_transform().get_origin()

func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position()

func initialize_piece(_piece_type: PieceEnum.PieceType):
	piece_type = _piece_type
	sprite.region_rect = Rect2(PieceEnum.PieceAtlas[_piece_type], 0, PIECE_SIZE, PIECE_SIZE)

func set_piece_position(hex: Vector2i):
	global_position = tile_map.map_to_local(hex) + DROP_OFFSET

func _on_area_2d_input_event(_viewport, event: InputEvent, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			dragging = true
		elif event.is_released():
			dragging = false
			set_piece_position(tile_map.local_to_map(get_global_mouse_position() - DROP_OFFSET))
