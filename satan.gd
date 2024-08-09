extends CharacterBody3D

const SPEED = 3.0
@export var turn_speed = 4.0
var str_comm
var anim_tree : AnimationTree  # Reference to the AnimationTree node
var health = 100
@onready var anim_state
var is_dead = false
var attacks = [
	"kick",
	"punch"
]
var atk_hit_miss = [true , false]
var ht_miss


func _ready():
	str_comm = get_tree().get_nodes_in_group("str_comm")[0]
	anim_tree = $AnimationTree  # Assuming the AnimationTree is a child node of this script
	anim_state = anim_tree.get("parameters/playback")  # Initialize anim_state after anim_tree is ready

func _physics_process(delta):
		
	if is_dead:
		anim_state.travel('idle')  # Transition to the idle animation   # Stop all animations by disabling the AnimationTree
		return

	else:
		var target_position = str_comm.global_transform.origin
		$FaceDirection.look_at(target_position, Vector3.UP)
		$idle.look_at(target_position, Vector3.DOWN)

		var direction_to_target = (target_position - global_transform.origin).normalized()
		var target_rotation = direction_to_target.angle_to(Vector3.FORWARD)
		rotation.y = lerp_angle(rotation.y, target_rotation, turn_speed * delta)

		$NavigationAgent3D.set_target_position(target_position)
		var velocity = (target_position - transform.origin).normalized() * SPEED

		# Update the animation parameters
		anim_tree.set("parameters/IWR/blend_position", Vector2(-velocity.x, velocity.z) / SPEED)

		# Move and collide
		move_and_collide(velocity * delta)


func _on_area_3d_body_entered(body):
	ht_miss = atk_hit_miss.pick_random()
	if ht_miss:
		if body.is_in_group("str_comm"):
			anim_state.travel(attacks.pick_random())
			get_tree().call_group('str_comm','hurt', 5)
	else:
		pass

func damage(dmg):
	if dmg < health:
		health -= dmg
	else:
		health = 0
	$SubViewport/Main_Enemy.value = health
	if health == 0:
		die()
	
		
func die():
	anim_state.travel("dying")
	is_dead = true
