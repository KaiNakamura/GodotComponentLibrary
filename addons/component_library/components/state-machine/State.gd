class_name State extends Node

@warning_ignore("unused_signal")
signal transition_to(state_name: String)

var state_machine: StateMachine

func enter() -> void:
	pass

func exit() -> void:
	pass

@warning_ignore("unused_parameter")
func update(delta: float) -> void:
	pass

@warning_ignore("unused_parameter")
func physics_update(delta: float) -> void:
	pass

@warning_ignore("unused_parameter")
func handle_input(event: InputEvent) -> void:
	pass

func get_actor() -> Node:
	return state_machine.actor
