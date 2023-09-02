extends Node3D

@export var player_scene: PackedScene
@onready var players: Node3D = $Players


func _ready() -> void:
	# a playable character is created for each player
	for player_data in Game.players:
		# we instantiate a character
		var player = player_scene.instantiate()
		# it gets added as a child of "players" node
		players.add_child(player)
		# setup for authority and other settings
		player.setup(player_data)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
