extends CharacterBody3D

@export var walking_speed = 6
@export var gravity = 15
@export var jump_impulse = 10
@export var mouse_sensibility = 0.05
@export var target_velocity = Vector3.ZERO

# direction of the player
var direction : Vector3
# direction input
var dir_input : Vector2
# model that change
var model
# showing mouse or not
var showing_mouse = false
# second jump
var second_jump = false
# animation_player
var player_animation
# timeout
var timeout = false

# we get the head node
@onready var head = $Head
# we get the camera node 
@onready var camera = $Head/Camera3D
# set the model
@onready var playable_character = $Playable_characters
# we get the animation tree
@onready var anim_tree : AnimationTree = $AnimationTree
# we get the animation playback of the animation tree 
@onready var playback : AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")
# we get the area to pass the bomb
@onready var area = $Area3D


# this function gets called when players are playable characters are assigned to each player
func setup(player_data: Game.PlayerData):
	# multiplayer authority with the given id
	set_multiplayer_authority(player_data.id)
	# if the character is not being controlled by the player, the it doesn't detect their input
	set_process_input(player_data.id == multiplayer.get_unique_id()) 
	# we deactivate physics process for the character not controlled by the player
	set_physics_process(player_data.id == multiplayer.get_unique_id())
	# we only activate the apropiate cameras
	camera.current = player_data.id == multiplayer.get_unique_id()
	# the name also gets saved
	name = str(player_data.id)
	# Setting up model character
	setup_model(player_data.role)
	# connect to the emit die
	if is_multiplayer_authority(): 
		Global.die.connect(player_die)

func setup_model(role):
	match role:
		1:
			model = load("res://resources/playable_character/mage.tscn").instantiate() as Node3D
		2:
			model = load("res://resources/playable_character/knight.tscn").instantiate() as Node3D
		3:
			model = load("res://resources/playable_character/rogue.tscn").instantiate() as Node3D

	model.rotation = Vector3(0, PI, 0)
	playable_character.add_child(model)
	# Setting up model visibility
	if is_multiplayer_authority():
		model.visible = true
	
	player_animation = model.get_child(1)
	anim_tree.anim_player = player_animation.get_path()

func _ready():
	# we hide cursor so we can move the camera freely
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# set animation tree to active
	anim_tree.active = true

func _input(event):
	# if we detect mouse movement
	if event is InputEventMouseMotion:
		# we rotate the whole player horizontally
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensibility))
		# we rotate just the head vertically so the rotations don't mess up with eachother
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensibility))
		# we clamp so we can look at most straight down and straight up
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2 )
		
func _process(_delta):
	pass

func _physics_process(delta):
	# return other players physics
	if not is_multiplayer_authority():
		return
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
	
	dir_input = Input.get_vector("move_left", "move_right", "move_backwards", "move_forwards")
	
	# direction we are meant to move	
	direction += transform.basis.z * -dir_input.y
	direction += transform.basis.x * dir_input.x
	
	if is_on_floor():
		target_velocity.y = 0
	
	# when passing the bomb
	if Input.is_action_just_pressed("ui_accept") and name == Global.bomb_carrier:
		for i in area.get_overlapping_bodies():
			if i == self:
				continue
			elif i is CharacterBody3D:
				i.pass_the_bomb(i.name)
				break
	
	# when sprinting
	if Input.is_action_pressed("sprint") and is_on_floor():
		player_speed = 3 * walking_speed
	
	# jumping
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			target_velocity.y += jump_impulse
		elif is_on_wall() and !second_jump:
			second_jump = true
			target_velocity.y += jump_impulse
	
	if is_on_floor():
		second_jump = false
	
	# gravity
	if not is_on_floor():
		target_velocity.y -= gravity * delta
	
	# we get the velocity vector of movement	
	target_velocity.x = direction.x * player_speed
	target_velocity.z = direction.z * player_speed
	
	velocity = target_velocity
	
	anim_tree.set("parameters/conditions/is_idle", dir_input == Vector2.ZERO && is_on_floor())
	anim_tree.set("parameters/conditions/is_walking", dir_input!= Vector2.ZERO && is_on_floor())
	anim_tree.set("parameters/conditions/is_walking_b", dir_input.x < 0 && is_on_floor())
	anim_tree.set("parameters/conditions/is_jumping", Input.is_action_just_pressed("jump")) # adjust animation
	anim_tree.set("parameters/conditions/is_falling", !is_on_floor())
	anim_tree.set("parameters/conditions/is_landing", is_on_floor())
	anim_tree.set("parameters/conditions/is_interact", Input.is_action_just_pressed("ui_accept") && name == Global.bomb_carrier)
	
	move_and_slide()

func pass_the_bomb(player_id):
	Global.update_the_bomb.rpc(player_id)
	
func player_die():
	anim_tree.set("parameters/conditions/is_dead", true)
	# disable input and process
	set_process_unhandled_input(false)
#	set_physics_process(false)
