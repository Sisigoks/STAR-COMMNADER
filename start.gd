extends Node3D

@onready var cam = $CAM

var target_angle = 90.0  # Target angle to rotate to
var rot_speed = 8.0  # Rotation speed in degrees per second
var current_angle = 0.0  # Current angle of rotation
var rotating_forward = true  # Direction of rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var angle_step = rot_speed * delta
	
	if rotating_forward:
		current_angle += angle_step
		if current_angle >= target_angle:
			current_angle = target_angle
			rotating_forward = false
	else:
		current_angle -= angle_step
		if current_angle <= 0.0:
			current_angle = 0.0
			rotating_forward = true

	# Apply the rotation to the camera
	cam.rotation_degrees.y = current_angle
