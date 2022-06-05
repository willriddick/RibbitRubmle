extends Control

var character = preload("res://scenes/character.tscn")

var connected_controllers: Array = []
var ready: bool = false
var selecting: bool = true


func _ready():
	global.initialize_skin_array(global.SKINS_AMOUNT)


enum CONTROLS {
	A = 0
}
var just_pressed_a: Array = [false]

func _process(_delta):
	if (selecting):
		set_visible(true)
		update_input()
		if (global.player_list.size() > 1):
			ready = true
			for i in range(0, global.player_list.size()):
				if (global.player_list[i].ready == false):
					ready = false
	else:
		ready = false
		set_visible(false)


func update_input() -> void:
	just_pressed_a.resize(Input.get_connected_joypads().size())
	
	#DEBUG TESTING
	if Input.is_action_just_pressed("ui_down"):
		connected_controllers.append(1)
		var c = character.instance()
		c.player_index = 1
		get_node("PlayerContainer").add_child(c)
		global.player_list.append(c)
		player_ready(1)
	
	for i in range(0, clamp(Input.get_connected_joypads().size(), 0, global.MAX_PLAYERS)):
		if (Input.is_joy_button_pressed(i, CONTROLS.A)):
			if (just_pressed_a[i] == false):
				just_pressed_a[i] = true
				if (connected_controllers.has(i) == false):
					player_add(i)
				else:
					player_ready(i)
		else:
			just_pressed_a[i] = false


func player_add(index: int) -> void:
	connected_controllers.append(index)
	var c = character.instance()
	c.player_index = index
	get_node("PlayerContainer").add_child(c)
	global.player_list.append(c)


func player_ready(index: int) -> void:
	var p = global.player_list[index]
	p.ready = true
	p.ready_up()
