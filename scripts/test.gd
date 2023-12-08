extends Node3D

@onready var player_animation : AnimationPlayer = $Node3D/Mage/AnimationPlayer
@onready var anim_tree : AnimationTree = $AnimationTree
@onready var playback : AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_tree.anim_player = player_animation.get_path()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("move_forwards"):
		playback.travel("Running_A")
		$Control/w_key.frame = 1
	elif Input.is_action_pressed("move_backwards"):
		playback.travel("Running_B")
		$Control/s_key.frame = 1
	elif Input.is_action_pressed("move_left"):
		playback.travel("Running_Strafe_Right")
		$Control/a_key.frame = 1
	elif Input.is_action_pressed("move_right"):
		playback.travel("Running_Strafe_Left")
		$Control/d_key.frame = 1
	elif Input.is_action_pressed("jump"):
		playback.travel("Jump_Full_Long")
		$Control/space_key.frame = 1
	elif Input.is_action_pressed("action_1"):
		playback.travel("Interact")
		$Control/mouse.frame = 1
	elif Input.is_action_pressed("action_2"):
		$Control/mouse.frame = 2
	else:
		playback.travel("Idle")
		$Control/w_key.frame = 0
		$Control/a_key.frame = 0
		$Control/s_key.frame = 0
		$Control/d_key.frame = 0
		$Control/space_key.frame = 0
		$Control/mouse.frame = 0
