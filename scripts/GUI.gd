extends Control

@onready var bomb_sprite = $bomb_sprite
@onready var time_label = $CenterContainer/HBoxContainer/TimerLabel
@onready var anim_player = $AnimationPlayer

# DEBUG
@onready var vel = $VBoxContainer/Vel
@onready var dir = $VBoxContainer/Dir
@onready var dir_input = $VBoxContainer/Dir_inp

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_gui()
	time_label.text = str(int(Global.global_timer.time_left))
	
	# DEBUG
	if is_multiplayer_authority():
		var velocity = get_parent().target_velocity
		vel.text = str("VEL: %s %s %s" % [velocity.x, velocity.y, velocity.z])
		var di = get_parent().direction
		dir.text = str("DIR: %s %s %s" % [di.x, di.y, di.z])
		var di_i = get_parent().dir_input
		dir_input.text = str("DIR INP: %s %s" % [di_i.x, di_i.y])

func update_gui():
	if StringName("%s" % Game.get_current_player().id) == Global.bomb_carrier:
		bomb_sprite.visible = true
	else:
		bomb_sprite.visible = false
