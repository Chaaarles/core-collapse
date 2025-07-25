extends Node2D

@export var arc_radius: float = 10.0
@export var initial_color: Color = Color(1.0, 1.0, 0.25)
@export var enc_color: Color = Color(0.3882353, 0.003921569, 0.003921569)

@onready var repair_audio_player: AudioStreamPlayer2D = $RepairAudioStream
@onready var decay_audio_player: AudioStreamPlayer2D = $DecayAudioStream

var decay_time: float      = 3.0
var decay_countdown: float = 0.0
var time: float            = 0.0
var arc: Node
var arcOutline: Node
var brokenCore: Sprite2D
var collisionShape: StaticBody2D
var is_player_inside: bool = false


func _ready() -> void:
	arc        = get_node("Arc")
	arcOutline = get_node("ArcOutline")
	brokenCore = get_node("BrokenCore")
	collisionShape = get_node("StaticBody2D")


func _process(delta: float) -> void:
	time += delta

	var decaying: bool = false
	if (decay_countdown > 0.0):
		decaying = true
		decay_countdown -= delta
		if decay_countdown <= 0.0:
			decay_countdown = 0.0
			decayed_signal.emit()

	if (decaying):
		brokenCore.visible = true
		arc.visible = true
		arcOutline.visible = true
		brokenCore.modulate = Color(1.0, 1.0, 1.0, 1.0 - decay_countdown / decay_time)
	else:
		brokenCore.modulate = Color(1.0, 1.0, 1.0, 1.0)

	var start_angle: float = time
	var end_angle: float   = start_angle + 2 * PI

	arc.start_angle = start_angle
	arc.end_angle = end_angle
	arcOutline.start_angle = start_angle
	arcOutline.end_angle = end_angle

	var radius: float = arc_radius + 2 * sin(time * 5.0)
	arc.radius = radius
	arcOutline.radius = radius

	var timer_ratio: float = 1 - clamp(decay_countdown / decay_time, 0.0, 1.0)
	var eased_ratio: float = ease(timer_ratio, 0.6)
	arc.color = lerp(initial_color, enc_color, eased_ratio)

	if (is_player_inside):
		arcOutline.color = Color(1.0, 1.0, 1.0, 1.0)
	else:
		arcOutline.color = Color(0.0, 0.0, 0.0, 1.0)


func startDecay(duration: float) -> void:
	if (decay_countdown <= 0.0):
		decay_time = duration
		decay_countdown = decay_time
		decay_audio_player.play()


func repair() -> void:
	if (decay_countdown > 0.0):
		decay_countdown = 0.0
		brokenCore.visible = false
		arc.visible = false
		arcOutline.visible = false
		repair_signal.emit()
		repair_audio_player.play()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if !body_is_player(body):
		return

	is_player_inside = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if !body_is_player(body):
		return

	is_player_inside = false


func body_is_player(body: Node2D) -> bool:
	return body.name == "Player"


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("repair") && is_player_inside:
		repair()

signal repair_signal
signal decayed_signal


func reset() -> void:
	decay_countdown = 0.0
	brokenCore.visible = false
	arc.visible = false
	arcOutline.visible = false
	repair_audio_player.stop()
	decay_audio_player.stop()
	arc.color = initial_color
	arcOutline.color = Color(0.0, 0.0, 0.0, 1.0)
	brokenCore.modulate = Color(1.0, 1.0, 1.0, 1.0)