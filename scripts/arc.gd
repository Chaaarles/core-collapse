extends Node2D

@export var radius: float = 10.0
@export var start_angle: float = 0.0
@export var end_angle: float = 2 * PI
@export var width: float = 1.0
@export var color: Color = Color.WHITE
@export var point_count: int = 7

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, start_angle, end_angle, point_count, color, width, false)
