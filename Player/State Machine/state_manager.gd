extends Node

@onready var states = {
	BaseState.State.Idle: $idle_state,
	BaseState.State.Walk: $walk_state,
	BaseState.State.Attack: $attack_state,
	BaseState.State.Death: $death_state
}

var current_state: BaseState

func change_state(new_state: int) -> void:
	if current_state:
		current_state.exit()
	
	current_state = states[new_state]
	current_state.enter()
	
	get_parent().get_node("Networking").sync_character_state = new_state

#Initialize state machine by giving states access to player
func init(player: Player) -> void:
	for child in get_children():
		child.player = player
	
	#set default state
	change_state(BaseState.State.Idle)

func physics_process(delta: float) -> void:
	var new_state = current_state.physics_process(delta)
	if new_state != BaseState.State.Null:
		change_state(new_state)

func input(event: InputEvent) -> void:
	var new_state = current_state.input(event)
	if new_state != BaseState.State.Null:
		change_state(new_state)
