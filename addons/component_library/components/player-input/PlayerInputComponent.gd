class_name PlayerInputComponent extends Node

@export var device_number: int
@export var default_input_memory: Dictionary[String, float] = {}
@export var default_cooldowns: Dictionary[String, float] = {}

var input_memory: Dictionary[String, Timer] = {}
var cooldowns: Dictionary[String, Timer] = {}

# TODO: Maybe add support for any devices (not useful for DennyGame, but would
# probably like to have in the future for other games

func _set_timer(timer_dict: Dictionary[String, Timer], action: String, duration: float) -> void:
	if action in timer_dict:
		timer_dict[action].stop()
		timer_dict[action].start(duration)
	else:
		var timer = Timer.new()
		timer.set_wait_time(duration)
		timer.set_one_shot(true)
		timer.timeout.connect(_on_timeout.bind(timer_dict, action))
		add_child(timer)
		timer.start()
		timer_dict[action] = timer

func _remove_timer(timer_dict: Dictionary[String, Timer], action: String) -> void:
	var timer := timer_dict[action]
	timer_dict.erase(action)
	timer.queue_free()

func _on_timeout(timer_dict: Dictionary[String, Timer], action: String) -> void:
	_remove_timer(timer_dict, action)

## Durations < 0 will use the default value
func remember_input(action: String, duration: float = -1) -> void:
	if duration < 0:
		if default_input_memory.has(action):
			duration = default_input_memory[action]
		else:
			return
	_set_timer(input_memory, action, duration)

## Durations < 0 will use the default value
func set_cooldown(action: String, duration: float = -1) -> void:
	if duration < 0:
		if default_cooldowns.has(action):
			duration = default_cooldowns[action]
		else:
			return
	_set_timer(cooldowns, action, duration)

func is_input_remembered(action: String) -> bool:
	return action in input_memory

func is_on_cooldown(action: String) -> bool:
	return action in cooldowns

func get_cooldown_time_left(action: String) -> float:
	if is_on_cooldown(action):
		return cooldowns[action].get_time_left()
	return 0

func remove_remembered_input(action: String) -> void:
	_remove_timer(input_memory, action)

func remove_cooldown(action: String) -> void:
	_remove_timer(cooldowns, action)

## Durations < 0 will use the default value
func perform_action_with_input_memory(action: String, callable: Callable, pressed: bool, input_memory_duration: float = -1, can_press: bool = true, cooldown: float = -1):
	if pressed:
		remember_input(action, input_memory_duration)
	
	var is_action_inputted = pressed or is_input_remembered(action)
	if is_action_inputted and can_press and not is_on_cooldown(action):
		callable.call()
		
		# Remove action from input memory
		remove_remembered_input(action)
		
		# Set cooldown
		set_cooldown(action, cooldown)

func left() -> String:
	return "left_" + str(device_number)

func right() -> String:
	return "right_" + str(device_number)

func up() -> String:
	return "up_" + str(device_number)

func down() -> String:
	return "down_" + str(device_number)

func left_action() -> String:
	return "left_action_" + str(device_number)

func right_action() -> String:
	return "right_action_" + str(device_number)

func top_action() -> String:
	return "top_action_" + str(device_number)

func bottom_action() -> String:
	return "bottom_action_" + str(device_number)

func left_trigger() -> String:
	return "left_trigger_" + str(device_number)

func right_trigger() -> String:
	return "right_trigger_" + str(device_number)

func left_bumper() -> String:
	return "left_bumper_" + str(device_number)

func right_bumper() -> String:
	return "right_bumper_" + str(device_number)

func left_stick_left() -> String:
	return "left_stick_left_" + str(device_number)

func left_stick_right() -> String:
	return "left_stick_right_" + str(device_number)

func left_stick_up() -> String:
	return "left_stick_up_" + str(device_number)

func left_stick_down() -> String:
	return "left_stick_down_" + str(device_number)

func right_stick_left() -> String:
	return "right_stick_left_" + str(device_number)

func right_stick_right() -> String:
	return "right_stick_right_" + str(device_number)

func right_stick_up() -> String:
	return "right_stick_up_" + str(device_number)

func right_stick_down() -> String:
	return "right_stick_down_" + str(device_number)

func d_pad_left() -> String:
	return "d_pad_left_" + str(device_number)

func d_pad_right() -> String:
	return "d_pad_right_" + str(device_number)

func d_pad_up() -> String:
	return "d_pad_up_" + str(device_number)

func d_pad_down() -> String:
	return "d_pad_down_" + str(device_number)
