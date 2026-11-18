extends Control


@export_group("Configuración")
@export var GYRO_SENSITIVITY : float = 60.0
@export var MIN_GYRO_PERMITTED : float = 0.8
@export var SMOOTH_SPEED : float = 25.0 
var is_calibrating : bool = false
var target_position: Vector2

func _ready():
	
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	target_position = position

	if 0 not in Input.get_connected_joypads():
		return

	if not Input.has_joy_motion_sensors(0):
		return

	Input.set_joy_motion_sensors_enabled(0, true)
	calibrate_motion()

func _process(delta):
	if Input.is_joy_motion_sensors_calibrated(0):
		move_object(delta)

func _input(event: InputEvent):
	if event is InputEventJoypadButton:
		# Y Recentrar cursor
		if event.pressed and event.button_index == JOY_BUTTON_Y:
			recenter_pointer()
		if event.button_index == JOY_BUTTON_A or event.button_index == JOY_BUTTON_RIGHT_SHOULDER:
			simulate_mouse_click(event.pressed)


func simulate_mouse_click(is_pressed: bool):
	var click_event := InputEventMouseButton.new()
	click_event.button_index = MOUSE_BUTTON_LEFT
	click_event.pressed = is_pressed
	click_event.position = get_pointer_hotspot()
	click_event.global_position = get_pointer_hotspot()
	
	Input.parse_input_event(click_event)

func get_pointer_hotspot() -> Vector2:
	return global_position + (size / 2.0)

func recenter_pointer():
	var current_window_size := Vector2(DisplayServer.window_get_size())
	var center_pos := (current_window_size - size) / 2.0
	
	target_position = center_pos
	position = center_pos
	rotation = 0.0

func calibrate_motion():
	is_calibrating = true
	Input.start_joy_motion_sensors_calibration(0)
	await get_tree().create_timer(1.0).timeout
	Input.stop_joy_motion_sensors_calibration(0)
	is_calibrating = false

func move_object(delta):
	var gyro := Input.get_joy_gyroscope(0)
	
	if abs(gyro.y) > MIN_GYRO_PERMITTED:
		target_position.x -= gyro.y * GYRO_SENSITIVITY * delta

	if abs(gyro.x) > MIN_GYRO_PERMITTED:
		target_position.y -= gyro.x * GYRO_SENSITIVITY * delta

	var current_window_size := Vector2(DisplayServer.window_get_size())
	target_position.x = clamp(target_position.x, 0.0, current_window_size.x - size.x)
	target_position.y = clamp(target_position.y, 0.0, current_window_size.y - size.y)

	var weight := 1.0 - exp(-SMOOTH_SPEED * delta)
	position = position.lerp(target_position, weight)
	
	var motion_event := InputEventMouseMotion.new()
	motion_event.position = get_pointer_hotspot()
	motion_event.global_position = get_pointer_hotspot()
	Input.parse_input_event(motion_event)
