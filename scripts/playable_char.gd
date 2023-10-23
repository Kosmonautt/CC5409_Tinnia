extends CharacterBody3D

var ACELERATION = 5
const MAX_SPEED = 30
@export var player_speed : int = 5
@export var gravity : int = 18
@export var jump_impulse : int = 8
@export var mouse_sensibility : float = 0.05
@export var target_velocity : Vector3 = Vector3.ZERO

# direction of the player
var direction : Vector3
# direction input
var dir_input : Vector2
# speed
var speed : Vector3
# model that change
var model
# showing mouse or not
var showing_mouse : bool = false
# second jump
var second_jump : bool = false
# animation_player
var player_animation

# we get the head node
@onready var head = $Head
# we get the camera node 
@onready var camera : Camera3D = $Head/Camera3D
# set the model
@onready var playable_character = $Playable_characters
# we get the animation tree
@onready var anim_tree : AnimationTree = $AnimationTree
# we get the animation playback of the animation tree 
@onready var playback : AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")
# we get the area to pass the bomb
@onready var area : Area3D = $Area3D
# bomb sprite texture
@onready var bomb_png : AnimatedSprite3D = $Playable_characters/Bomb_Sprite


# this function gets called when players are playable characters are assigned to each player
func setup(player_data: Game.PlayerData) -> void:
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

func setup_model(role : Game.Role) -> void:
	match role:
		1:
			model = load("res://resources/playable_character/mage.tscn").instantiate() as Node3D
		2:
			model = load("res://resources/playable_character/knight.tscn").instantiate() as Node3D
		3:
			model = load("res://resources/playable_character/rogue.tscn").instantiate() as Node3D
		4:
			model = load("res://resources/playable_character/barbarian.tscn").instantiate() as Node3D

	model.rotation = Vector3(0, PI, 0)
	playable_character.add_child(model)
	# Setting up model visibility
	if is_multiplayer_authority():
		model.visible = true
	
	player_animation = model.get_node("%AnimationPlayer")
	anim_tree.anim_player = player_animation.get_path()

func _ready():
	# we hide cursor so we can move the camera freely
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# set animation tree to active
	anim_tree.active = true
	# show bomb png
	bomb_png.play()

func _input(event):
	# if we detect mouse movement
	if event is InputEventMouseMotion:
		# we rotate the whole player horizontally
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensibility))
		# we rotate just the head vertically so the rotations don't mess up with eachother
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensibility))
		# we clamp so we can look at most straight down and straight up
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2 )
		
		
func amove_to(x: float, y: float, delta: float) -> float:
	if x >= y:
		return y
	else:
		x += delta
		return x

func _process(_delta):
	if Global.bomb_carrier == name.to_int():
		if is_multiplayer_authority():
			bomb_png.visible = false
		else:
			bomb_png.visible = true
	else:
		bomb_png.visible = false

func _physics_process(delta):
	# return other players physics
	if not is_multiplayer_authority():
		return
	
	# if we try to exit
	if Input.is_action_just_pressed("ui_cancel"):
		if not showing_mouse:
			# the mouse becomes visible so we can click the X
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			showing_mouse = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			showing_mouse = false
			
	# when passing the bomb
	if Input.is_action_just_pressed("action_1") and name.to_int() == Global.bomb_carrier:
		for i in area.get_overlapping_bodies():
			if i == self:
				continue
			elif i is CharacterBody3D and Global.is_player_alive(i.name.to_int()):
				animation_state.rpc("Interact")
				i.pass_the_bomb(i.name.to_int())
				break
	
	# jumping Y
	if is_on_floor():
		target_velocity.y = 0
		second_jump = false
	else:
		animation_state.rpc("Jump_Idle")
		target_velocity.y -= gravity * delta
		
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			animation_state.rpc("Jump_Start")
			target_velocity.y += jump_impulse
		elif is_on_wall() and !second_jump:
			animation_state.rpc("Jump_Start")
			second_jump = true
			target_velocity.y += jump_impulse
	
	# when sprinting
	if Input.is_action_pressed("sprint"):
		ACELERATION = 10
	
	# direction vector of movement
	direction = Vector3.ZERO
	# direction vector of input
	dir_input = Vector2.ZERO
	
	dir_input = Input.get_vector("move_left", "move_right", "move_backwards", "move_forwards")
	direction = (transform.basis * Vector3(dir_input.x, 0, -dir_input.y))
	
	if is_on_floor():
		if dir_input:
			speed.x = move_toward(speed.x, MAX_SPEED, ACELERATION * delta)
			speed.z = move_toward(speed.z, MAX_SPEED, ACELERATION * delta)
	
			target_velocity.x = direction.x * speed.x
			target_velocity.z = direction.z * speed.z
		else:
			target_velocity.x = move_toward(target_velocity.x, 0, ACELERATION * 5 * delta)
			target_velocity.z = move_toward(target_velocity.z, 0, ACELERATION * 5 * delta)
			speed = Vector3.ZERO
			
	velocity = target_velocity
	print(velocity)
	
	anim_tree.set("parameters/Movement/blend_position", Vector2(velocity.x, velocity.z))
	anim_tree.set("parameters/conditions/is_landed", is_on_floor())
	anim_tree.set("parameters/conditions/is_on_air", !is_on_floor())
	
	move_and_slide()

func pass_the_bomb(player_id : int) -> void:
	Global.update_the_bomb.rpc(player_id)
	
	
func player_die() -> void:
	animation_state.rpc("Death_A")
	# disable input and process
	set_process_unhandled_input(false)
	set_physics_process(false)

@rpc("call_local")
func animation_state(current_animation : String):
	playback.travel(current_animation)
