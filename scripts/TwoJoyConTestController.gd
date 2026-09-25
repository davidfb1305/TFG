extends Node

@export var blueCube: Node3D # LeftJoycon
@export var redCube: Node3D   # RightJoyCon

# We save the current IDs of the JoyCon (we are going to assigned them later) 
var leftId = -1;
var rightId = -1;
	

	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Tells SDL not to combine both JoyCons
	OS.set_environment("SDL_JOYSTICK_HIDAPI_COMBINE_JOY_CONS", "0");

	# Register the conected joycon
	for device_id in Input.get_connected_joypads():
		JoyConRegister(device_id)
	
	# Detects if the joycons are connected
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

#If the device is changed we register our joycon again, if the devide is -1 we reset the Ids
func _on_joy_connection_changed(device_id: int, connected: bool):
	if connected:
		JoyConRegister(device_id)
	else:
		if device_id == leftId: leftId = -1
		if device_id == rightId: rightId = -1

func JoyConRegister(device_id: int):
	
	var name = Input.get_joy_name(device_id).to_lower()
	
	# Using name left and right we search for the joy con names 
	# Esto no me gusta mucho pero es lo unico que he encontrado :(
	if "left" in name or "joy-con (l)" in name:
		leftId = device_id
		print("Joy-Con Izquierdo asignado al dispositivo de entrada: ", device_id)
	elif "right" in name or "joy-con (r)" in name:
		rightId = device_id
		print("Joy-Con Derecho asignado al dispositivo de entrada: ", device_id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Blue controleer
	if leftId != -1:

		# The numbers 4,5,6 are for driver axis the numbers 
		var acc_x = Input.get_joy_axis(leftId, 4) 
		var acc_y = Input.get_joy_axis(leftId, 5)
		var acc_z = Input.get_joy_axis(leftId, 6)
		
		var leftacelerometerVector = Vector3(acc_x, acc_y, acc_z)
		

		blueCube.rotate_x(leftacelerometerVector.x * delta)
		blueCube.rotate_y(leftacelerometerVector.y * delta)


	# RedCube controler
	if rightId != -1:
		var acc_x_der = Input.get_joy_axis(rightId, 4) 
		var acc_y_der = Input.get_joy_axis(rightId, 5)
		var acc_z_der = Input.get_joy_axis(rightId, 6)
		
		var rightacelerometerVector = Vector3(acc_x_der, acc_y_der, acc_z_der)
		
		
		redCube.rotate_x(rightacelerometerVector.x * delta)
		redCube.rotate_y(rightacelerometerVector.y * delta)
