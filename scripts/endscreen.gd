extends CanvasLayer

@onready var winner_label : Label = $ControlScreen/MarginContainer/VBoxContainer2/VBoxContainer/WinnerLabel
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var mainmenu_button : Button = $ControlScreen/MarginContainer/VBoxContainer2/VBoxContainer2/mainmenu_bottom
var showing_mouse : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("background_move")
	winner_label.text = Global.winner_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if not showing_mouse:
			# the mouse becomes visible so we can click the X
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			showing_mouse = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			showing_mouse = false


func _on_mainmenu_bottom_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _on_exit_pressed():
	get_tree().quit()


func _on_play_again_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/lobby.tscn")
