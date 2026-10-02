extends Node3D
const GYRO_SENSITIVITY = 1.0
const MIN_GYRO_PERMITTED = 0.6;

func _ready():
	# In this example we only use the first connected joypad (id 0).
	if 0 not in Input.get_connected_joypads():
		return

	if not Input.has_joy_motion_sensors(0):
		return

	# We must enable the motion sensors before using them.
	Input.set_joy_motion_sensors_enabled(0,true)

	# (Tell the users here that they need to put their joypads on a flat surface and wait for confirmation.)

	# Start the calibration process.
	calibrate_motion()

func _process(delta):
	# Only move the object if the joypad motion sensors are calibrated.
	if Input.is_joy_motion_sensors_calibrated(0):
		move_object(delta)

func calibrate_motion():
	Input.start_joy_motion_sensors_calibration(0)

	# Wait for some time.
	await get_tree().create_timer(1.0).timeout

	Input.stop_joy_motion_sensors_calibration(0)
	# The joypad is now calibrated.

func move_object(delta):
	var node: Node3D = self
	var gyro := Input.get_joy_gyroscope(0)

	# Inclinación vertical (Pitch - Eje X)
	if abs(gyro.x) > MIN_GYRO_PERMITTED:
		# Cambia a '-=' si la rotación vertical sigue invertida
		node.rotation.x -= gyro.x * GYRO_SENSITIVITY * delta  

	# Giro horizontal (Yaw - Eje Y)
	if abs(gyro.y) > MIN_GYRO_PERMITTED:
		# Cambia a '+=' si la rotación horizontal se invierte
		node.rotation.y -= gyro.y * GYRO_SENSITIVITY * delta
	

