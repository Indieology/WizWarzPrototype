extends Node
class_name BaseState

enum State {
	Null,
	Idle,
	Walk,
	Attack,
	Death
}

@export var animation_name : String

var player: Player

func enter() -> void:
	pass

func exit() -> void:
	pass

func input(event: InputEvent) -> int:
	return State.Null

func process(delta: float) -> int:
	return State.Null

func physics_process(delta: float) -> int:
	return State.Null
