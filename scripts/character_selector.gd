extends Node3D

var active_animation_player : AnimationPlayer
var model
@onready var characters : Node3D = $Characters
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var playback : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func change_visible(role) -> void:
	if model != null:
		characters.remove_child(model)
	animation_tree.anim_player = $AnimationPlayer.get_path()
	match role:
		0: 
			active_animation_player = $AnimationPlayer
		1: 
			model = load("res://resources/playable_character/mage.tscn").instantiate() as Node3D
			active_animation_player = model.get_node("%AnimationPlayer")
		2:
			model = load("res://resources/playable_character/knight.tscn").instantiate() as Node3D
			active_animation_player = model.get_node("%AnimationPlayer")
		3:
			model = load("res://resources/playable_character/rogue.tscn").instantiate() as Node3D
			active_animation_player = model.get_node("%AnimationPlayer")
		4:
			model = load("res://resources/playable_character/barbarian.tscn").instantiate() as Node3D
			active_animation_player = model.get_node("%AnimationPlayer")
			
	characters.add_child(model)
	animation_tree.anim_player = active_animation_player.get_path()
	animation_tree.active = true
	playback.travel("Cheer")
	await animation_tree.animation_finished
	playback.travel("Idle")
