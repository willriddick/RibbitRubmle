extends Node2D


var player_controller = preload("res://scenes/player_controller.tscn")

onready var player_container = get_node("PlayerContainer")
onready var level_container = get_node("LevelContainer")
var flip_level: bool = false
var level_index: int = 0
var level_array: Array = [
	"res://levels/level_1.tscn",
	"res://levels/level_2.tscn",
	"res://levels/level_3.tscn"
] 

onready var character_screen = get_node("UI/CharacterScreen") 


func _ready():
	randomize()


func _process(_delta):
	if (character_screen.ready == true):
		load_level(level_array[level_index])
		character_screen.selecting = false
	
	# DEBUG
	if (Input.is_action_pressed("control")):
		if (Input.is_action_just_pressed("ui_up")):
			level_index = global.wrap(level_index+1, 0, level_array.size()-1)
			load_level(level_array[level_index])
		if (Input.is_action_just_pressed("ui_down")):
			level_index = global.wrap(level_index-1, 0, level_array.size()-1)
			load_level(level_array[level_index])
		
		if (Input.is_action_just_pressed("toggle_fullscreen")):
			OS.window_fullscreen = !OS.window_fullscreen 
		if (Input.is_action_just_pressed("end")):
			get_tree().quit()
		if (Input.is_action_just_pressed("restart")):
			global.reset()
			var _d = get_tree().reload_current_scene()


func load_level(level_string: String):
	# CLEAR LEVEL
	if (level_container.get_child_count() > 0):
		for i in range(0, level_container.get_children().size()):
			var obj = level_container.get_child(i)
			obj.queue_free()
	
	# CLEAR PLAYERS
	if (player_container.get_child_count() > 0):
		for i in range(0, player_container.get_children().size()):
			var obj = player_container.get_child(i)
			obj.queue_free()
	
	# GET LEVEL
	var l = load(level_string)
	var level = l.instance()
	level_container.add_child(level)
	
	if (flip_level && randi() % 2 == 1):
		level_container.scale.x = -1
		level_container.global_position.x = 960
	else:
		level_container.scale.x = 1
	
	var spawn_points = level.get_node("Spawns").get_children()
	
	# SPAWN PLAYERS
	for i in range(0, global.player_list.size()):
		var p = player_controller.instance()
		p.spawn_pos = spawn_points[randi() % spawn_points.size()].global_position
		p.player_index = i
		p.skin_index = global.player_list[i].skin_index
		player_container.add_child(p)
	
	print(player_container.get_children())
