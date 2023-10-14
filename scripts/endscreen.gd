extends Node2D

@onready var winner_label = $VBoxContainer/WinnerLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	winner_label.text = str(Global.players_alive[0])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
