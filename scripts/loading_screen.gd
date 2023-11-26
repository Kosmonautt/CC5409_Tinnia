extends Control
@export var scene : String = "res://scenes/main.tscn"
@onready var progress_bar : ProgressBar = %ProgressBar
var progress = []
var scene_load_status = 0
var status = { 1 : false }

func _ready():
	send_status.rpc_id(1,  multiplayer.get_unique_id())
	ResourceLoader.load_threaded_request(scene)


func _process(_delta):
	scene_load_status = ResourceLoader.load_threaded_get_status(scene,progress)
	progress_bar.value = progress[0] * 100
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		_ready_for_play()
		#end_of_loading_screen()


@rpc("any_peer", "reliable")
func send_status(id : int) -> void:
	if multiplayer.is_server():
		status[id] = false
		print(status)
 

func _ready_for_play() -> void:
	if multiplayer.get_unique_id() == 1:
		await get_tree().create_timer(3).timeout
	player_ready.rpc_id(1, multiplayer.get_unique_id())


@rpc("reliable", "any_peer", "call_local")
func player_ready(id: int):
	if multiplayer.is_server():
		status[id] = true
		var all_ok = true
		for ok in status.values():
			all_ok = all_ok and ok
		if all_ok:
			end_of_loading_screen()


func end_of_loading_screen():
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		# get_tree().change_scene_to(ResourceLoader.load_threaded_get(scene))
		start_game.rpc()
		queue_free()
	else:
		print("Scene not loaded or in progress")


@rpc("any_peer", "call_local", "reliable")
func start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
