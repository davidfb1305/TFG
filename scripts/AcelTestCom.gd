extends Node3D
var detect_accelerometer = true
@export var speed : float = 2
# Change to make the game detect movement at different thresholds.
# With a lower value, smaller movements will be detected, and with a
# larger value, only big movements will be detected.
const THRESHOLD = 10.0

func _ready():
	# In this example, we only use the first connected joypad (ID 0).
	if 0 not in Input.get_connected_joypads():
		return

	if not Input.has_joy_motion_sensors(0):
		return

	# We must enable the motion sensors before using them.
	Input.set_joy_motion_sensors_enabled(0, true)

func _process(delta):
	if Input.has_joy_motion_sensors(0):
		accelerometer_example()

func accelerometer_example():
	if not detect_accelerometer:
		return

	var acceleration = Input.get_joy_accelerometer(0) - Input.get_joy_gravity(0)
	if acceleration.length() > THRESHOLD:
		if acceleration.x > THRESHOLD:
			print("Moved left")
			position.x -=speed*get_process_delta_time()
		elif acceleration.x < -THRESHOLD:
			print("Moved right")
			position.x +=speed*get_process_delta_time()
		if acceleration.y < -THRESHOLD:
			print("Moved up")
			position.y +=speed*get_process_delta_time()
		elif acceleration.y > THRESHOLD:
			print("Moved down")
			position.y -=speed *get_process_delta_time()
		if acceleration.z < -THRESHOLD:
			print("Moved closer to the player")
		elif acceleration.z > THRESHOLD:
			print("Moved away from the player")

		# After detecting movement in one direction, the accelerometer sensor
		# will briefly report movement in the opposite direction, even though the controller only moved once.
		# So we need to ignore these reported values for a short amount of time.
		detect_accelerometer = false
		await get_tree().create_timer(0.1, false).timeout
		detect_accelerometer = true
