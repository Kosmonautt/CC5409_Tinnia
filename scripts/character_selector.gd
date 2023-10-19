extends Node3D

@onready var characters : Node3D = $Characters

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func change_visible(role) -> void:
	match role:
		0: 
			$Characters/Mage.visible = false
			$Characters/Barbarian.visible = false
			$Characters/Rogue.visible = false
			$Characters/Knight.visible = false
			
		1: 
			$Characters/Mage.visible = true
			$Characters/Barbarian.visible = false
			$Characters/Rogue.visible = false
			$Characters/Knight.visible = false
		2: 
			$Characters/Mage.visible = false
			$Characters/Barbarian.visible = false
			$Characters/Rogue.visible = false
			$Characters/Knight.visible = true
		3: 
			$Characters/Mage.visible = false
			$Characters/Barbarian.visible = false
			$Characters/Rogue.visible = true
			$Characters/Knight.visible = false
		4:
			$Characters/Mage.visible = false
			$Characters/Barbarian.visible = true
			$Characters/Rogue.visible = false
			$Characters/Knight.visible = false
	
