extends CharacterBody3D

var ACELERATION = 5
var MAX_SPEED = 30
@export var player_speed : int = 5
@export var gravity : int = 20
@export var jump_impulse : int = 12
@export var max_up_speed : int = 20
@export var mouse_sensibility : float = 0.05

var direction : Vector3
var dir_input : Vector2
var speed : Vector3
var target_velocity : Vector3 = Vector3.ZERO
var model
var showing_mouse : bool = false
var second_jump : bool = false
var player_animation
var mage_tp : Area3D = null
var power_active : bool = false
var power_available : bool = true
var air_strafing_speed : float = 0
var pass_bomb : bool = true
var is_walking : bool = false

@onready var head = $Head
@onready var camera : Camera3D = $Head/Camera3D
@onready var playable_character = $Playable_characters
@onready var anim_tree : AnimationTree = $AnimationTree
@onready var playback : AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")
@onready var area : Area3D = $Area3D
@onready var bomb_png : AnimatedSprite3D = $Playable_characters/Bomb_Sprite
@onready var power_timer : Timer = $power_timer
@onready var particles : GPUParticles3D = $Particles
@onready var bomb_body : RigidBody3D = $Knight_bomb/RigidBody3D
@onready var sound : AudioStreamPlayer = $AudioStreamPlayer
@onready var sound3d : AudioStreamPlayer3D = $Playable_characters/AudioStreamPlayer3D
@onready var pause_menu : Control = $CanvasLayer/pause_menu
@onready var music : AudioStreamPlayer = $GlobalSongPlayer
var pausa = false

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
		Global.sound_tick.connect(sound_tick)
		music.play()
	# setting up the timer for the power
	setup_icon(player_data.role)

func setup_model(role : Game.Role) -> void:
	match role:
		1:
			model = load("res://resources/playable_character/mage.tscn").instantiate() as Node3D
			mage_tp = $Mage_TP
		2:
			model = load("res://resources/playable_character/knight.tscn").instantiate() as Node3D
		3:
			model = load("res://resources/playable_character/rogue.tscn").instantiate() as Node3D
		4:
			model = load("res://resources/playable_character/barbarian.tscn").instantiate() as Node3D

	model.rotation = Vector3(0, PI, 0)
	playable_character.add_child(model)
	player_animation = model.get_node("%AnimationPlayer")
	anim_tree.anim_player = player_animation.get_path()
	
func setup_icon(role : Game.Role) -> void:
	$GUI.setup_power(role)
	match role:
		1:
			power_timer.wait_time = 15
		2:
			power_timer.wait_time = 15
		3:
			power_timer.wait_time = 15
		4:
			power_timer.wait_time = 15

func _ready():
	# we hide cursor so we can move the camera freely
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# set animation tree to active
	anim_tree.active = true
	# show bomb png
	bomb_png.play()
	add_to_group("Players")

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
	if Global.bomb_carrier == name.to_int():
		if is_multiplayer_authority():
			bomb_png.hide()
		else:
			bomb_png.show()
	else:
		bomb_png.hide()
		
	if power_timer.time_left < 10 and power_active:
		particle_emit.rpc("res://resources/assets/powers/Neutral_particles.tres")
		normal_state()
		power_active = false
		
func _physics_process(delta):
	# to avoid getting stuck on the ceiling
	if not is_on_floor() and is_on_ceiling():
		target_velocity.y = 0
	
	# return other players physics
	if not is_multiplayer_authority():
		return
		
	# activate power
	if Input.is_action_just_pressed("action_2") and power_available and not Global.on_prep_time:
		character_power(Game.get_current_player().role)

	# when passing the bomb
	if Input.is_action_just_pressed("action_1") and name.to_int() == Global.bomb_carrier and pass_bomb:
		for i in area.get_overlapping_bodies():
			if i == self:
				continue
			elif i is CharacterBody3D and Global.is_player_alive(i.name.to_int()):
				animation_state.rpc("Interact")
				sound.stream = load("res://resources/sounds/bomb_given.wav")
				sound.play()
				i.pass_the_bomb(i.name.to_int())
				bomb_recibed.rpc_id(i.name.to_int())
				i.start_pass_timer.rpc()
				await anim_tree.animation_finished
				animation_state.rpc("Movement")
				break
	
	# jumping Y
	if is_on_floor():
		target_velocity.y = 0
		second_jump = false
	else:
		animation_state.rpc("Jump_Idle")
		target_velocity.y -= gravity * delta
		
	if Input.is_action_just_pressed("jump") and not pausa:
		if is_on_floor():
			animation_state.rpc("Jump_Start")
			target_velocity.y += jump_impulse
			air_strafing_speed = Vector2(velocity.x, velocity.z).length()
			
		elif is_on_wall() and !second_jump:
			animation_state.rpc("Jump_Start")
			second_jump = true
			target_velocity.y += jump_impulse
		
		emit_sound.rpc("res://resources/sounds/jump.wav")
		# max upward speed is limited
		target_velocity.y = min(target_velocity.y, max_up_speed)
	
	# when sprinting
	if Input.is_action_pressed("sprint"):
		ACELERATION = 10
	
	# direction vector of movement
	direction = Vector3.ZERO
	# direction vector of input
	dir_input = Vector2.ZERO
	
	dir_input = Input.get_vector("move_left", "move_right", "move_backwards", "move_forwards")
	direction = (transform.basis * Vector3(dir_input.x, 0, -dir_input.y))
	if pausa:
		direction = (transform.basis * Vector3(0, 0, 0))
	
	if is_on_floor():
		if !is_walking and dir_input:
			is_walking = true
			emit_sound.rpc("res://resources/sounds/walk.wav")
		elif is_walking and dir_input == Vector2.ZERO:
			stop_sound.rpc()
			is_walking = false
	
	if not Global.on_prep_time:
		if is_on_floor():
			if dir_input:
				speed.x = move_toward(speed.x, MAX_SPEED, ACELERATION * delta)
				speed.z = move_toward(speed.z, MAX_SPEED, ACELERATION * delta)
		
				target_velocity.x = direction.x * speed.x
				target_velocity.z = direction.z * speed.z
			else:
				is_walking = false
				target_velocity.x = move_toward(target_velocity.x, 0, ACELERATION * 5 * delta)
				target_velocity.z = move_toward(target_velocity.z, 0, ACELERATION * 5 * delta)
				speed = Vector3.ZERO
		else:
			target_velocity.x = -get_global_transform().basis.z[0]*air_strafing_speed
			target_velocity.z = -get_global_transform().basis.z[2]*air_strafing_speed
			
		velocity = target_velocity
	
	anim_tree.set("parameters/Movement/blend_position", Vector2(target_velocity.x, target_velocity.z))
	anim_tree.set("parameters/conditions/is_landed", is_on_floor())
	
	move_and_slide()

func pass_the_bomb(player_id : int) -> void:
	Global.update_the_bomb.rpc(player_id)

func player_die() -> void:
	animation_state.rpc("Death_A")
	sound.stream = load("res://resources/sounds/explosion.wav")
	sound.play()
	emit_sound.rpc("res://resources/sounds/explosion.wav")
	# disable input and process
	set_process_unhandled_input(false)
	set_physics_process(false)
	disable_collision.rpc()
	
@rpc("call_local")
func disable_collision():
	gravity = 0
	$CollisionShape3D.disabled = true

@rpc("call_local")
func animation_state(current_animation : String):
	playback.travel(current_animation)

func is_valid_place():
	return !mage_tp.has_overlapping_areas() and !mage_tp.has_overlapping_bodies()
	
func mage_power():
	particle_emit.rpc("res://resources/assets/powers/Mage_particles.tres")
	position = mage_tp.global_position
	
func knight_power():
	animation_state.rpc("Throw")
	bomb_body.position = position + (1 * -transform.basis.z)
	bomb_body.show()
	bomb_body.freeze = false
	bomb_body.linear_velocity += (20 * -head.get_global_transform().basis.z) + target_velocity
	await anim_tree.animation_finished
	animation_state.rpc("Movement")

@rpc("call_local")
func rogue_power():
	particle_emit("res://resources/assets/powers/Rogue_particles.tres")
	power_active = true
	self.scale *= 0.5

func barbarian_power():
	particle_emit("res://resources/assets/powers/Barbarian_particles.tres")
	power_active = true
	jump_impulse = 20
	ACELERATION = 12
	MAX_SPEED = 60
	player_speed = 8

func character_power(role : Game.Role):
	match role:
		1:
			if is_valid_place():
				mage_power()
			else:
				return
		2:
			knight_power()
		3:
			rogue_power.rpc()
		4:
			barbarian_power()
	power_timer.start()
	sound.stream = load("res://resources/sounds/pop.wav")
	sound.play()
	power_available = false
	$GUI.hide_power_icon()

func normal_state():
	self.scale = Vector3(1, 1, 1)
	ACELERATION = 5
	MAX_SPEED = 30
	player_speed = 5
	jump_impulse = 12
	
@rpc("any_peer", "call_local")
func particle_emit(material_path : String):
	sound.stream = load("res://resources/sounds/pop.wav")
	sound.play()
	var material : SphereMesh = load(material_path)
	particles.draw_pass_1 = material
	particles.emitting = true
	particles.restart()

func _on_power_timer_timeout():
	power_available = true
	if bomb_body.position != Vector3.ZERO:
		bomb_body.freeze = true
		bomb_body.hide()
		bomb_body.position = Vector3(0, 0, 0)
	$GUI.show_power_icon()

func _on_rigid_body_3d_body_entered(body):
	if body.is_in_group("Players"):
		if Global.bomb_carrier == name.to_int():
			pass_the_bomb(body.name.to_int())

@rpc("any_peer", "reliable")
func bomb_recibed():
	sound.stream = load("res://resources/sounds/bomb_recibed.wav")
	sound.play()

@rpc("any_peer", "reliable")
func start_pass_timer():
	$Pass_timer.start()
	pass_bomb = false

func _on_pass_timer_timeout():
	pass_bomb = true

func sound_tick():
	rpc_sound_tick.rpc()

@rpc("any_peer", "call_local", "reliable")
func rpc_sound_tick():
	sound.stream = load("res://resources/sounds/tick.wav")
	sound.play()

@rpc("any_peer","call_local", "reliable")
func emit_sound(sound_path : String):
	if !is_multiplayer_authority():
		sound3d.stream = load(sound_path)
		sound3d.play()

@rpc("any_peer","call_local", "reliable")
func stop_sound():
	sound3d.stop()

func _on_global_song_player_finished():
	if is_multiplayer_authority():
		music.play()
