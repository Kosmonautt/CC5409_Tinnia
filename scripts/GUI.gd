extends Control

@onready var bomb_sprite : AnimatedSprite2D = $bomb_sprite
@onready var time_label : Label = $CenterContainer/HBoxContainer/TimerLabel
@onready var anim_player : AnimationPlayer = $AnimationPlayer

# DEBUG
@onready var bomb : Label = $VBoxContainer/Label
@onready var pa : Label = $VBoxContainer/Label2


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_gui()
	time_label.text = str(int(Global.global_timer.time_left))
	
	# DEBUG
	if is_multiplayer_authority():
		var bomba : int = Global.bomb_carrier 
		bomb.text = str("BOMB CARRIER: %s" % bomba)


func update_gui() -> void:
	if Game.get_current_player().id == Global.bomb_carrier:
		bomb_sprite.visible = true
	else:
		bomb_sprite.visible = false
