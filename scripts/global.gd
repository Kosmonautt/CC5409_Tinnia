extends Node

@export var players_alive : Array = []
@onready var global_timer : Timer = Timer.new()
var bomb_carrier : int
@onready var winner_id : int = -1

# signal that connect to timeout
signal die()

# Called when the node enters the scene tree for the first time.
func _ready():
	global_timer.one_shot = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func game_ready() -> void:
	players_alive = Game.players.map(func(value): return value.id)
	add_child(global_timer)
	global_timer.start(30)
	# manage the timer on the multiplayer authority
	if is_multiplayer_authority():
		global_timer.timeout.connect(_on_global_timer_timeout)

@rpc("call_local")
func start_bomb(player_id : int):
	bomb_carrier = player_id

@rpc("any_peer", "call_local", "reliable")
func update_the_bomb(player_id : int):
	bomb_carrier = player_id
	
@rpc("call_local")
func emit_die() -> void:
	die.emit()
	
func _on_global_timer_timeout():
	emit_die.rpc_id(bomb_carrier)
	players_alive.erase(bomb_carrier)
	if players_alive.size() == 1:
		game_end.rpc(players_alive[0])
	else:
		var i : int = players_alive[randi() % players_alive.size()]
		update_the_bomb.rpc(i)

func is_player_alive(player_id : int) -> bool:
	for i in players_alive:
		if i == player_id:
			return true
	return false

@rpc("any_peer", "call_local", "reliable")
func game_end(id: int):
	winner_id = id
	get_tree().change_scene_to_file("res://scenes/ui/endscreen.tscn")
	Debug.dprint(id, 60)
	global_timer.stop()
