extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const ACCELERATION = 5.0
# Get the gravity from the project settings to be synced with Rigid Body nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var spring_arm = $SpringArm3D
@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")
@onready var model = $Idle  # Replace this with the path to your model if it's different.
@onready var health = 100
var is_dead = false
var in_satan_area
var satan

func _ready():
	anim_tree.active = true
	spring_arm.add_excluded_object(self)

func hurt(hit_points):
	if hit_points < health:
		health -= hit_points
	else:
		health = 0
	$SpringArm3D/Camera3D/ProgressBar.value = health
	if health == 0:
		die()
	
		
func die():
	anim_state.travel("dying")
	is_dead = true
	
		

func _physics_process(delta):
	
	if is_dead:
		return
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		anim_state.travel("jump")
		await get_tree().create_timer(0.7).timeout
		velocity.y = JUMP_VELOCITY

	# Store current y velocity
	var vy = velocity.y
	velocity.y = 0
	
	# Get input direction
	var input = Input.get_vector("left", "right", "forward", "back")
	var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, spring_arm.rotation.y)
	
	# Lerp velocity towards the input direction
	velocity = lerp(velocity, dir * SPEED, ACCELERATION * delta)
	
	# Make the model look in the direction of movement
	if dir.length() > 0:
		model.look_at(position - dir, Vector3.UP)
	
	# Calculate local velocity in model's space
	var vl = velocity * model.transform.basis
	
	# Set the animation blend position based on local velocity
	anim_tree.set("parameters/IWR/blend_position", Vector2(vl.x, -vl.z) / SPEED)
	
	# Restore y velocity
	velocity.y = vy
	
	if Input.is_action_just_pressed("punch"):
		anim_state.travel("punch")
	if Input.is_action_just_pressed("hook"):
		anim_state.travel("hook")
	if Input.is_action_just_pressed("kick"):
		anim_state.travel("kick")
		
	if in_satan_area:
		if Input.is_action_just_pressed("kick"):
			anim_state.travel('kick')
			get_tree().call_group('satan', 'damage', 5)
		elif Input.is_action_just_pressed("punch"):
			anim_state.travel('punch')
			get_tree().call_group('satan', 'damage', 5)
		elif Input.is_action_just_pressed("hook"):
			anim_state.travel('hook')
			get_tree().call_group('satan', 'damage', 5)
			
	var collision = move_and_collide(velocity * delta)
	if collision:
		var colliding_piece = collision.get_collider_shape_index()
		if colliding_piece == 25:
			print("exit door entered")

	move_and_slide()
		
func _on_area_3d_body_entered(body):
	if body.is_in_group("satan"):
		in_satan_area = true  # Mark that you're in the satan area

func _on_area_3d_body_exited(body):
	if body.is_in_group("satan"):
		in_satan_area = false  # Mark that you've left the satan area
		
