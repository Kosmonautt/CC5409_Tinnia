extends Node2D

@onready var winner_label : Label = $VBoxContainer/WinnerLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	winner_label.text = str(Global.winner_id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	pass
