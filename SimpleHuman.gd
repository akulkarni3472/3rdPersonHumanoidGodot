extends KinematicBody

export var speed = 10.0
export var lerp_val = 0.2
export var forward_tilt = 10
export var jump_force = 8.0
export var gravity = 9.8
export var grab_rotate_speed = 0.1

var moving = false
var velocity = Vector3.ZERO
var snap_vector = Vector3.DOWN

onready var spring_arm= $SpringArmPivot/SpringArm
onready var model = $Armature/Skeleton/Cube
onready var animation_player = $AnimationPlayer
# onready var grab_cast = $MeshInstance/GrabPos
# onready var hold_pos = $MeshInstance/GrabPos/HoldPos

var held_object: Object

func _physics_process(delta):
	apply_gravity(delta)
	move()
	jump()
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true)
	
func _process(delta):
	spring_arm.translation = translation

func move():
	animation_player.play("run_loop")
	var move_dir = Vector3.ZERO
	move_dir.x = Input.get_action_strength("right") - Input.get_action_raw_strength("left")
	move_dir.z = Input.get_action_strength("back") - Input.get_action_raw_strength("forward")
	move_dir = move_dir.rotated(Vector3.UP, spring_arm.rotation.y).normalized()
	velocity.x = move_dir.x * speed
	velocity.z = move_dir.z * speed
	if move_dir.z != 0 or move_dir.x != 0:
		model.rotation.y = lerp_angle(model.rotation.y, atan2(velocity.x, velocity.z), lerp_val)
		moving = true
	if moving:
		model.rotation.x = lerp_angle(model.rotation.x, -forward_tilt, lerp_val)

func apply_gravity(delta):
	velocity.y -= delta * gravity

func jump():
	var landed = is_on_floor() and snap_vector == Vector3.ZERO
	var jumping = is_on_floor() and Input.is_action_just_pressed("jump")
	
	if jumping:
		snap_vector = Vector3.ZERO
		velocity.y = jump_force
	elif landed:
		snap_vector = Vector3.DOWN
