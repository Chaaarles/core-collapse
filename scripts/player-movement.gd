extends CharacterBody2D

@export_group("Movement")
@export var speed := 200.0
@export_subgroup("Dash")
@export var dash_speed := 600
@export var dash_duration := 0.15
@export var dash_cooldown := 0.6
@export_group("Trail")
@export var trail_interval := 0.04

var trail_timer: float = 0.0

@export var trail_scene := preload("res://scenes/trail.tscn")

var direction      := Vector2.ZERO
var is_dashing     := false
var dash_timer     := 0.0
var cooldown_timer := 0.0
var boost_bar: ProgressBar


func _ready() -> void:
	boost_bar = %BoostBar
	if not boost_bar:
		print("BoostBar not found! Please ensure it is set in the scene.")
		return
	boost_bar.value = 100.0


func _physics_process(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
		boost_bar.value = 100.0 * (1.0 - cooldown_timer / dash_cooldown)

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
			cooldown_timer = dash_cooldown
		else:
			boost_bar.value = 100.0 * (dash_timer / dash_duration)

	else:
		direction = Vector2.ZERO

		if Input.is_action_pressed("ui_right"):
			direction.x += 1
		if Input.is_action_pressed("ui_left"):
			direction.x -= 1
		if Input.is_action_pressed("ui_down"):
			direction.y += 1
		if Input.is_action_pressed("ui_up"):
			direction.y -= 1

		if Input.is_action_just_pressed("dash") and cooldown_timer <= 0.0 and direction.length() > 0:
			is_dashing = true
			dash_timer = dash_duration

	if is_dashing:
		velocity = direction.normalized() * dash_speed

		trail_timer -= delta
		if trail_timer <= 0.0:
			spawn_trail()
			trail_timer = trail_interval
	else:
		velocity = direction.normalized() * speed

	move_and_slide()


func spawn_trail():
	var trail  = trail_scene.instantiate()
	trail.global_position = global_position
	var sprite = trail.get_node("Sprite2D")
	sprite.texture = $Sprite2D.texture
	sprite.flip_h = $Sprite2D.flip_h
	sprite.rotation = $Sprite2D.rotation
	sprite.scale = $Sprite2D.scale
	get_tree().current_scene.add_child(trail)
