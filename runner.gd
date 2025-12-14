class_name Runner
extends CharacterBody2D

## The top speed that the runner can achieve
@export var max_speed := 600.0
## How much speed is added per second when the player presses a movement key
@export var acceleration := 1200.0
## How much speed is lost per second when the player releases all movement keys
@export var deceleration := 1080.0

@onready var _runner_visual: RunnerVisual = %RunnerVisualRed
@onready var _dust: GPUParticles2D = %Dust

## Emitted when the character has walked to the specified destination.
signal walked_to

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var has_input_direction := direction.length() > 0.0
	if has_input_direction:
		var desired_velocity := direction * max_speed
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	move_and_slide()

	if direction.length() > 0.0:
		_runner_visual.angle = rotate_toward(_runner_visual.angle, direction.orthogonal().angle(), 8.0 * delta)

		var current_speed_percent := velocity.length() / max_speed
		_runner_visual.animation_name = (
			RunnerVisual.Animations.WALK
			if current_speed_percent < 0.8
			else RunnerVisual.Animations.RUN
		)
		_dust.emitting = true
	else:
		_runner_visual.animation_name = RunnerVisual.Animations.IDLE
		_dust.emitting = false

## Forces the character to walk to a position ignoring collisions[br]
## [param destination_global_position]: The desired destination, given in global coordinates.
func walk_to(destination_global_position: Vector2) -> void:
	# obtain the direction and angle
	var direction := global_position.direction_to(destination_global_position)
	_runner_visual.angle = direction.orthogonal().angle()

	# Set the proper animation name
	_runner_visual.animation_name = RunnerVisual.Animations.WALK
	_dust.emitting = true

	# obtain distance, and calculate direction from that
	var distance := global_position.distance_to(destination_global_position)
	var duration :=  distance / (max_speed * 0.2)

	# tween the runner to destination, then emit `walked_to`
	var tween := create_tween()
	tween.tween_property(self, "global_position", destination_global_position, duration)
	tween.finished.connect(func():
		_runner_visual.animation_name = RunnerVisual.Animations.IDLE
		_dust.emitting = false
		walked_to.emit()
)
