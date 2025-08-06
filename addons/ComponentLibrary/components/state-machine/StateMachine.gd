class_name StateMachine extends Node

signal switched_state(old_state: State, new_state: State)

@export var actor: Node
@export var initial_state: State

var states: Dictionary[String, State] = {}
var current_state: State

func add_state(state: State, name: String) -> void:
	states[name] = state
	state.state_machine = self
	state.transition_to.connect(_on_transition_to)
	
	# If state is not a child, add it
	# We do this to handle building state machines outside the editor
	if not state in get_children():
		add_child(state)

func set_initial_state(name: String) -> void:
	initial_state = states[name]

func get_current_state_name() -> String:
	return states.find_key(current_state)

func _ready() -> void:
	# Add all children as states
	for child in get_children():
		# Push error if child is not a State
		if not child is State:
			push_error("StateMachine found a child named '%s' that is not a State" % child.name)
			continue
			
		# Skip if already added
		if child in states.values():
			continue
		add_state(child, child.name)
	
	if not initial_state:
		push_error("No initial state specified for StateMachine")
		return
	initial_state.enter()
	current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func _on_transition_to(state_name: String) -> void:
	# Get the new state and make sure it exists
	var new_state: State = states[state_name]
	if not new_state:
		push_error("State not found with name %s" % state_name)
		return
	
	# Call exit on the current state
	if current_state:
		current_state.exit()
	
	# Call enter on the new state
	new_state.enter()
	
	# Update the current state
	var old_state := current_state
	current_state = new_state
	
	# Emit signal
	switched_state.emit(old_state, new_state)
