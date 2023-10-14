extends Node3D

@export var player_scene: PackedScene
@onready var players: Node3D = $Players
@onready var spawn: Node3D = $Spawn

func _ready() -> void:
	# we sort the player correctly
	Game.players.sort_custom(func (a, b): return a.id < b.id)
	
	# a playable character is created for each player
	for i in Game.players.size():
		# we get the palyer data
		var player_data = Game.players[i]
		# we instantiate a player
		var player = player_scene.instantiate()
		# it gets added as a child of "players" node
		players.add_child(player)
		# setup for authority and other settings
		player.setup(player_data)
		# we give each player a different position on the map
		player.global_position = spawn.get_child(i).global_position

	Global.game_ready()
	
	if multiplayer.is_server(): 
		Global.start_bomb.rpc(Game.players[randi() % Game.players.size()].id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
