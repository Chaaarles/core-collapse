extends CharacterBody2D

@export_group("Movement")
@export var speed := 200.0
@export_subgroup("Dash")
@export var dash_speed := 600
@export var dash_duration := 0.15
@export var dash_cooldown := 0.6
@export_group("Trail")
@export var trail_interval := 0.04

@onready var movement_audio: AudioStreamPlayer2D = $MovementAudio
@onready var boost_audio: AudioStreamPlayer2D = $BoostAudio

var trail_timer: float = 0.0

@export var trail_scene := preload("res://scenes/trail.tscn")

var direction         := Vector2.ZERO
var is_dashing        := false
var dash_timer        := 0.0
var cooldown_timer    := 0.0
var boost_bar: ProgressBar
var audio_ramp_factor := 0.0


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
			boost_audio.play()

	if is_dashing:
		velocity = direction.normalized() * dash_speed

		trail_timer -= delta
		if trail_timer <= 0.0:
			spawn_trail()
			trail_timer = trail_interval
	else:
		velocity = direction.normalized() * speed

	if velocity.length() > 0:
		audio_ramp_factor = min(1.0, audio_ramp_factor + delta * 4.0)
		if not movement_audio.playing:
			movement_audio.play()
	else:
		audio_ramp_factor = max(0.0, audio_ramp_factor - delta * 2.0)

	if audio_ramp_factor > 0.0:
		movement_audio.volume_db = lerp(-80.0, 0.0, ease(audio_ramp_factor, 0.3))
	else:
		movement_audio.stop()

	move_and_slide()


func spawn_trail():
	var trail: Node  = trail_scene.instantiate()
	trail.global_position = global_position
	var sprite: Node = trail.get_node("Sprite2D")
	sprite.texture = $Sprite2D.texture
	sprite.flip_h = $Sprite2D.flip_h
	sprite.rotation = $Sprite2D.rotation
	sprite.scale = $Sprite2D.scale
	get_tree().current_scene.add_child(trail)
