extends CharacterBody3D

@export var walking_speed = 6
@export var gravity = 9.8
@export var jump_impulse = 10
@export var mouse_sensibility = 0.05

# direction of the player
var direction

# direction input
var dir_input

# velocity of the player
var target_velocity = Vector3.ZERO

# we get the head node
@onready var head = $Head

# showing mouse or not
var showing_mouse = false

# second jump
var second_jump = false

func _ready():
	# we hide cursor so we can move the camera freely
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# if we detect mouse movement
	if event is InputEventMouseMotion:
		# we rotate the whole player horizontally
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensibility))
		# we rotate just the head vertically so the rotations don't mess up with eachother
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensibility))
		# we clamp so we can look at most straight down and straight up
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2 )
	

func _physics_process(delta):	
	# direction vector of movement
	direction = Vector3.ZERO
	# direction vector of input
	dir_input = Vector2.ZERO
	
	# real movement speed of the character
	var player_speed = walking_speed
	
	# if we try to exit
	if Input.is_action_just_pressed("ui_cancel"):
		if not showing_mouse:
			# the mouse becomes visible so we can click the X
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			showing_mouse = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			showing_mouse = false
					
	var dir_input = Input.get_vector("move_left", "move_right", "move_backwards", "move_fowards")
	
	# direction we are meant to move	
	direction += transform.basis.z * -dir_input.y
	direction += transform.basis.x * dir_input.x
	
	# when sprinting
	if Input.is_action_pressed("sprint") and is_on_floor():
		player_speed = 3 * walking_speed
	
	# jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		target_velocity.y = jump_impulse
		
	# wall jump
	if Input.is_action_just_pressed("jump") and is_on_wall() and !second_jump:
		second_jump = true
		target_velocity.y = jump_impulse
		
	if is_on_floor():
		second_jump = false
	
	# gravity
	if not is_on_floor():
		target_velocity.y -= gravity * delta
	
	# we get the velocity vector of movement	
	target_velocity.x = direction.x * player_speed
	target_velocity.z = direction.z * player_speed
	
	velocity = target_velocity
			
	move_and_slide()
