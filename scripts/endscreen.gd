extends CanvasLayer

@onready var winner_label : Label = $ControlScreen/MarginContainer/VBoxContainer2/VBoxContainer/WinnerLabel
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var mainmenu_button : Button = $ControlScreen/MarginContainer/VBoxContainer2/mainmenu_bottom

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("background_move")
	winner_label.text = Global.winner_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	pass


func _on_mainmenu_bottom_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn") # Replace with function body.


func _on_exit_pressed():
	get_tree().quit() # Replace with function body.
