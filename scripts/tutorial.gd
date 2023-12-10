extends Node3D

@onready var player_animation : AnimationPlayer = $Node3D/Mage/AnimationPlayer
@onready var anim_tree : AnimationTree = $AnimationTree
@onready var playback : AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")
@onready var back_button : Button = $Control/Button
var opened : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_tree.anim_player = player_animation.get_path()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_pressed("move_forwards"):
		playback.travel("Running_A")
		$Control/w_key.frame = 1
		$Control/Label.text = "Movement"
	elif Input.is_action_pressed("move_backwards"):
		playback.travel("Walking_Backwards")
		$Control/s_key.frame = 1
		$Control/Label.text = "Movement"
	elif Input.is_action_pressed("move_left"):
		playback.travel("Running_Strafe_Right")
		$Control/a_key.frame = 1
		$Control/Label.text = "Movement"
	elif Input.is_action_pressed("move_right"):
		playback.travel("Running_Strafe_Left")
		$Control/d_key.frame = 1
		$Control/Label.text = "Movement"
	elif Input.is_action_pressed("jump"):
		playback.travel("Jump_Full_Long")
		$Control/space_key.frame = 1
		$Control/Label.text = "Jump"
	elif Input.is_action_pressed("action_1"):
		playback.travel("Interact")
		$Control/mouse.frame = 1
		$Control/Label.text = "Pass the bomb"
	elif Input.is_action_pressed("action_2"):
		$Control/mouse.frame = 2
		$Control/Label.text = "Use power"
		$Control/Label2.show()
		$Control/powers.show()
		if !opened:
			$Control/powers.play("default")
			opened = true
	else:
		playback.travel("Idle")
		$Control/w_key.frame = 0
		$Control/a_key.frame = 0
		$Control/s_key.frame = 0
		$Control/d_key.frame = 0
		$Control/space_key.frame = 0
		$Control/mouse.frame = 0
		$Control/Label.text = ""

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
