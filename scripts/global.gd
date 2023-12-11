extends Node

const TIMER_TIME : int = 50
@export var players_alive : Array = []
@onready var global_timer : Timer = Timer.new()
@onready var sound_timer : Timer = Timer.new()
var on_prep_time : bool = true
var bomb_carrier : int
@onready var winner_name : String = "unname"

# signal that connect to timeout
signal die()
signal sound_tick()

# Called when the node enters the scene tree for the first time.
func _ready():
	global_timer.one_shot = false
	sound_timer.one_shot = true

# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(_delta):
	pass

func game_ready() -> void:
	players_alive = Game.players.map(func(value): return value.id)
	add_child(global_timer)
	global_timer.start(TIMER_TIME)
	add_child(sound_timer)
	sound_timer.start(TIMER_TIME-8)
	await get_tree().create_timer(TIMER_TIME-40).timeout
	end_of_prep_time()
	# manage the timer on the multiplayer authority
	if is_multiplayer_authority():
		global_timer.timeout.connect(_on_global_timer_timeout)
		
	if is_multiplayer_authority():
		sound_timer.timeout.connect(_on_sound_timer_timeout)

@rpc("call_local")
func start_bomb(player_id : int):
	bomb_carrier = player_id

@rpc("any_peer", "call_local", "reliable")
func update_the_bomb(player_id : int):
	bomb_carrier = player_id
	
@rpc("call_local")
func emit_die() -> void:
	die.emit()
	
@rpc("call_local")
func emit_sound_tick() -> void:
	sound_tick.emit()
	
func _on_global_timer_timeout():
	sound_timer.start(TIMER_TIME-8)
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

func end_of_prep_time():
	on_prep_time = false

func is_player_alive(player_id : int) -> bool:
	for i in players_alive:
		if i == player_id:
			return true
	return false

@rpc("any_peer", "call_local", "reliable")
func game_end(winner: String):
	winner_name = winner
	get_tree().change_scene_to_file("res://scenes/ui/endscreen.tscn")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	global_timer.stop()
	
@rpc("any_peer", "call_local")
func new_carrier():
	if multiplayer.is_server():
		var i : int = players_alive[randi() % players_alive.size()]
		update_the_bomb.rpc(i)

@rpc("any_peer", "call_local")
func elim_people(id :int):
	players_alive.erase(id)

func player_disconect(id: int):
	emit_die.rpc_id(id)
	elim_people.rpc(id)
	if id == bomb_carrier:
		new_carrier.rpc()
	if players_alive.size() == 1:
		var id_aux : int = players_alive[0]
		var player_name : String = "nada"
		for i in Game.players:
			if id_aux == i.id:
				player_name = i.name
				break
		game_end.rpc(player_name)

func _on_sound_timer_timeout():
	emit_sound_tick.rpc_id(bomb_carrier)
