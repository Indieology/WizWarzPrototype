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
	player.animation_player.play(animation_name)
	get_parent().get_parent().get_node("Networking").sync_character_animation = animation_name

func exit() -> void:
	pass

func input(event: InputEvent) -> int:
	return State.Null

func process(delta: float) -> int:
	return State.Null

func physics_process(delta: float) -> int:
	return State.Null
