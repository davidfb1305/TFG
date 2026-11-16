extends Node3D

@export var sensitivity: float = 0.5

@export_group("Márgenes de la Cámara")
@export var min_bounds: Vector3 = Vector3(-5.0, -3.0, 0.0)
@export var max_bounds: Vector3 = Vector3(5.0, 3.0, 0.0)

const JOYPAD_ID = 0
const deadzone: float = 0.5
const suavizado: float = 20.0
var initial_position: Vector3
var target_position: Vector3

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
	
	#Comprobamos si hay mando conectado
	if not Input.is_joy_motion_sensors_enabled(JOYPAD_ID):
		return

	#Si se pulsa el botón de restart mandar la posición al lugar de origen
	if Input.is_joy_button_pressed(JOYPAD_ID, JOY_BUTTON_A):
		target_position = initial_position
		position = initial_position
		return

	
	#Guardamos Accel para más adelante
	var accel: Vector3 = Input.get_joy_accelerometer(JOYPAD_ID)

	#DeadZones
	if abs(accel.x) < deadzone: accel.x = 0.0
	if abs(accel.y) < deadzone: accel.y = 0.0

	var movement := Vector3(accel.x, accel.z, 0.0) * sensitivity * delta

	target_position += movement * 2;  #Este *2 es para que el objeto viaje más rápido a la posición a la que apunto

	#Limites de pantalla
	target_position = target_position.clamp(min_bounds, max_bounds)

	# Suavizar el movimiento real hacia la posición objetivo
	position = position.lerp(target_position, suavizado * delta)
