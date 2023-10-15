extends Node

@export var players_alive : Array = []
@onready var global_timer : Timer = Timer.new()
var bomb_carrier : int
@onready var winner_name : String = "unname"

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
	global_timer.start(100)
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
		var id : int = players_alive[0]
		var player_name : String = "nada"
		for i in Game.players:
			if id == i.id:
				player_name = i.name
				break
		game_end.rpc(player_name)
	else:
		var i : int = players_alive[randi() % players_alive.size()]
		update_the_bomb.rpc(i)

func is_player_alive(player_id : int) -> bool:
	for i in players_alive:
		if i == player_id:
			return true
	return false

@rpc("any_peer", "call_local", "reliable")
func game_end(winner: String):
	winner_name = winner
	get_tree().change_scene_to_file("res://scenes/ui/endscreen.tscn")
	global_timer.stop()
