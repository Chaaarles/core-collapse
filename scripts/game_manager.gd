extends Node

@export var cores: Array[NodePath] = []
@export var initial_decay_interval: float = 6.0
@export var min_decay_interval: float = 2.0
@export var initial_decay_duration: float = 3.0
@export var min_decay_duration: float = 1.0
@export var difficulty_curve: float = 0.4
@export var time_to_max_difficulty: float = 120.0

var decay_countdown: float = 2.0
var time: float            = 0.0
var score: int             = 0
var game_over: bool        = false


func _ready() -> void:
	if cores.size() == 0:
		print("No cores assigned for decay. Please assign core nodes in the inspector.")
		return

	# Connect to core repair and decay signals
	for core_path in cores:
		var core: Node = get_node(core_path)
		if core.has_signal("repair_signal") and core.has_signal("decayed_signal"):
			core.connect("repair_signal", _on_core_repair)
			core.connect("decayed_signal", _on_core_decayed)


func _process(delta: float) -> void:
	if game_over:
		return

	time += delta

	var difficulty_ratio: float = ease(clamp(time / time_to_max_difficulty, 0.0, 1.0), difficulty_curve)
	var decay_interval          = lerp(initial_decay_interval, min_decay_interval, difficulty_ratio)
	var decay_duration          = lerp(initial_decay_duration, min_decay_duration, difficulty_ratio)

	if (decay_countdown > 0.0):
		decay_countdown -= delta
		if decay_countdown <= 0.0:
			decay_countdown = decay_interval
			var core: Node
			# Randomly select a core to decay
			if cores.size() > 0:
				core = get_node(cores[randi() % cores.size()])
				if core.has_method("startDecay"):
					core.startDecay(decay_duration)
			else:
				print("No cores available for decay.")


func _on_core_repair() -> void:
	score += 1
	%ScoreLabel.text = str(score)
	%FinalScore.text = str(score)


func _on_core_decayed() -> void:
	game_over = true
	%GameOverContainer.visible = true


func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("restart_game") && game_over):
		%GameOverContainer.visible = false
		game_over = false
		score = 0
		time = 0.0
		decay_countdown = 2.0
		for core_path in cores:
			var core: Node = get_node(core_path)
			if core.has_method("reset"):
				core.reset()
		%ScoreLabel.text = "0"
		%FinalScore.text = "0"
