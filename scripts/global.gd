extends Node

@onready var global_timer : Timer = Timer.new()
var bomb_carrier : StringName

# Called when the node enters the scene tree for the first time.
func _ready():
	global_timer.one_shot = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func game_ready():
	add_child(global_timer)
	global_timer.start(5)

@rpc("call_local")
func start_bomb(player_id):
	bomb_carrier = StringName("%s" % player_id)

@rpc("any_peer", "call_local", "reliable")
func update_the_bomb(player_id):
	bomb_carrier = player_id
	

@rpc("call_local")
func new_timer():
#	global_timer.start(10)
	pass
