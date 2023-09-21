extends Node

@onready var global_timer : Timer = Timer.new()
var bomb_carrier : StringName
@export var players_alive : Array = []

# signal that connect to timeout
signal die()

# Called when the node enters the scene tree for the first time.
func _ready():
	global_timer.one_shot = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func game_ready():
	players_alive = Game.players.map(func(value): return value.id)
	add_child(global_timer)
	global_timer.start(10)
	# manage the timer on the multiplayer authority
	if is_multiplayer_authority():
		global_timer.timeout.connect(_on_global_timer_timeout)

@rpc("call_local")
func start_bomb(player_id):
	bomb_carrier = StringName("%s" % player_id)

@rpc("any_peer", "call_local", "reliable")
func update_the_bomb(player_id):
	bomb_carrier = player_id
	
@rpc("call_local")
func emit_die():
	die.emit()
	
func _on_global_timer_timeout():
	print(players_alive)
	Debug.dprint("Murio %s" % bomb_carrier, 9)
	emit_die.rpc_id(bomb_carrier.to_int())
	players_alive.erase(bomb_carrier.to_int())
#	if players_alive.size() == 1:
#		Debug.dprint("GANASTE")
	# nuevo jugador que tiene la bomba
	var i = players_alive[randi() % players_alive.size()]
	Debug.dprint("ASIGNO RANDOM A %s" % i)
	update_the_bomb.rpc(StringName("%s" % i))
