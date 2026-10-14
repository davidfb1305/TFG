extends Node3D

@export var sensitivity: float = 1.0

@export_group("Márgenes de la Cámara")
@export var min_bounds: Vector3 = Vector3(-5.0, -3.0, 0.0)
@export var max_bounds: Vector3 = Vector3(5.0, 3.0, 0.0)

const JOYPAD_ID = 0
var initial_position: Vector3

func _ready() -> void:
	initial_position = position

	if JOYPAD_ID not in Input.get_connected_joypads():
		print("Aviso: No hay ningún mando conectado.")
		return

	if not Input.has_joy_motion_sensors(JOYPAD_ID):
		print("Aviso: El mando no cuenta con sensores de movimiento.")
		return

	Input.set_joy_motion_sensors_enabled(JOYPAD_ID, true)

func _process(delta: float) -> void:
	
	if Input.is_joy_button_pressed(JOYPAD_ID, JOY_BUTTON_A):
		position = initial_position
		return

	if not Input.has_joy_motion_sensors(JOYPAD_ID):
		return

	var acceleration = Input.get_joy_accelerometer(JOYPAD_ID) - Input.get_joy_gravity(JOYPAD_ID)

	var deadzone = 0.5
	if abs(acceleration.x) < deadzone: acceleration.x = 0.0
	if abs(acceleration.y) < deadzone: acceleration.y = 0.0

	var direction = Vector3(acceleration.x, -acceleration.y, 0.0)

	position += direction * sensitivity * delta

	position.x = clamp(position.x, min_bounds.x, max_bounds.x)
	position.y = clamp(position.y, min_bounds.y, max_bounds.y)
	position.z = clamp(position.z, min_bounds.z, max_bounds.z)
