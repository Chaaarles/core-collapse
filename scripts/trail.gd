extends Node2D

@export var lifetime := 0.2
var time := 0.0

@onready var sprite := $Sprite2D

func _ready() -> void:
	time = lifetime

func _process(delta: float) -> void:
	time -= delta
	var alpha = time / lifetime
	sprite.modulate.a = alpha
	if time <= 0:
		queue_free()
