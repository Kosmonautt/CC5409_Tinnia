extends Control

@onready var bomb_sprite : AnimatedSprite2D = $bomb/bomb_sprite
@onready var time_label : Label = $CenterContainer/bomb_timer/TimerLabel
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var power_icon : Sprite2D = %power_icon
@onready var chronometer_sprite : Sprite2D = $CenterContainer/bomb_timer/chronometer_sprite

# DEBUG
@onready var bomb : Label = $VBoxContainer/Label
@onready var pa : Label = $VBoxContainer/Label2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_gui()
	if Global.on_prep_time:
		chronometer_sprite.hide()
		time_label.text = "The Game starts in " + str(int(Global.global_timer.time_left)-40+1) 
	else:
		chronometer_sprite.show()
		time_label.text = str(int(Global.global_timer.time_left)+1)
	
	# DEBUG
	if is_multiplayer_authority():
#		var bomba : bool = $"../".pass_bomb
#		var bomba : int = Global.bomb_carrier
		var bomba : int = $"../".is_walking
		bomb.text = str("BOMB CARRIER: %s" % bomba)

func update_gui() -> void:
	if Game.get_current_player().id == Global.bomb_carrier:
		bomb_sprite.show()
	else:
		bomb_sprite.hide()

func setup_power(role : Game.Role) -> void:
	var power : String
	match role:
		1:
			power = "res://resources/assets/powers/Mage.png"
		2:
			power = "res://resources/assets/powers/Knight.png"
		3:
			power = "res://resources/assets/powers/Rogue.png"
		4:
			power = "res://resources/assets/powers/Barbarian.png"
	power_icon.texture = load(power)
	
	if is_multiplayer_authority():
		show_power_icon()
	
func show_power_icon() -> void:
	power_icon.show()
	
func hide_power_icon() -> void:
	power_icon.hide()
