extends Node2D

@onready var animation_knight : AnimationPlayer = $CanvasLayer/Node3D/Knight/AnimationPlayer
@onready var animation_mage : AnimationPlayer = $CanvasLayer/Node3D/Mage/AnimationPlayer
@onready var animation_barbarian : AnimationPlayer = $CanvasLayer/Node3D/Barbarian/AnimationPlayer
@onready var animation_rogue : AnimationPlayer = $CanvasLayer/Node3D/Rogue/AnimationPlayer

@onready var knight = $CanvasLayer/Node3D/Knight
@onready var barbarian = $CanvasLayer/Node3D/Barbarian
@onready var mage = $CanvasLayer/Node3D/Mage
@onready var rogue = $CanvasLayer/Node3D/Rogue

@export var scene : String = "res://scenes/ui/main_menu.tscn"
@export var scene2 : String = "res://scenes/ui/lobby.tscn"
@onready var progress_bar : ProgressBar = %ProgressBar

var progress = []
var progress2 = []
var scene_load_status = 0
var scene_load_status2 = 0
var seconds_passed = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	knight.hide()
	barbarian.hide()
	mage.hide()
	rogue.hide()
	$Timer.start()
	ResourceLoader.load_threaded_request(scene)
	ResourceLoader.load_threaded_request(scene2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	scene_load_status = ResourceLoader.load_threaded_get_status(scene,progress)
	scene_load_status2 = ResourceLoader.load_threaded_get_status(scene2,progress2)
	progress_bar.value = progress[0] * 100
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED and scene_load_status2 == ResourceLoader.THREAD_LOAD_LOADED and seconds_passed == 2.5:
		starting_game()

func _on_timer_timeout():
	seconds_passed += 0.5
	if seconds_passed == 0.5:
		knight.visible = true
		animation_knight.play("2H_Melee_Attack_Chop")
	elif seconds_passed == 1:
		rogue.visible = true
		animation_rogue.play("1H_Ranged_Shoot")
	elif seconds_passed == 1.5:
		mage.visible = true
		animation_mage.play("2H_Melee_Attack_Chop")
	elif seconds_passed == 2:
		barbarian.visible = true
		animation_barbarian.play("1H_Melee_Attack_Slice_Horizontal")
	elif seconds_passed == 2.5:
		$Timer.stop()

func starting_game():
	var newScene = ResourceLoader.load_threaded_get(scene)
	get_tree().change_scene_to_packed(newScene)
	queue_free()
