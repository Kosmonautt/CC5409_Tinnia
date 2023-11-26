extends Control

@onready var playable_character = $"../../"
@onready var settings = $MarginContainer/VBoxContainer/settings
var pausa = false


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	Game.paused.connect(_on_game_paused) # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _input(event):
	if is_multiplayer_authority():
		if event.is_action_pressed("pause"):
#			Game.pause.rpc(!get_tree().paused)
			pauseMenu()

func _on_resumen_pressed():
	pauseMenu()
#	Game.pause.rpc(false)

func _on_game_paused():
	visible = get_tree().paused
	
	if get_tree().paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func pauseMenu():
	if pausa:
		hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#		playable_character.pausa = false
		playable_character.set_process_input(true)
#		Engine.time_scale = 1
	else:
		show()
		playable_character.set_process_input(false)
#		playable_character.pausa = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#		Engine.time_scale = 0
	
	playable_character.pausa = !playable_character.pausa
	pausa = !pausa
