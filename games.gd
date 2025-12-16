extends Node2D

@onready var _finish_line: FinishLine = %FinishLine

func _ready() -> void:
	_finish_line.body_entered.connect(func (body: Node) -> void:
	
	
		if body is not Runner:
			return
		var runner := body as Runner

		runner.set_physics_process(false)
		var destination_position := (
			_finish_line.global_position
			+ Vector2(0, 64)
		)
		
		runner.walk_to(destination_position)
		runner.walked_to.connect(
			_finish_line.pop_confettis
		)
	)
	
	_finish_line.confettis_finished.connect(
		get_tree().reload_current_scene.call_deferred
	)
