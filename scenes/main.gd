extends Node3D

@export var player_scene: PackedScene
@onready var players: Node3D = $Players
@onready var spawn: Node3D = $Spawn

func _ready() -> void:
	# a playable character is created for each player
	for i in Game.players.size():
		# we get the palyer data
		var player_data = Game.players[i]
		# we instantiate a player
		var player = player_scene.instantiate()
		# it gets added as a child of "players" node
		players.add_child(player)
		# setup for authority and other settings
		#player.setup(player_data)
		player.global_position = spawn.get_child(i).global_position
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
