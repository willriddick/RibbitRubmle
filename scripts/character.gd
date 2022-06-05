extends Control


onready var label = get_node("ColorRect/Label")
onready var sprite = get_node("ColorRect/Sprite")
var player_index: int
var ready: bool = false
var skin_select: int = 0
var skin_index: int = 0


func _ready():
	label.set_text("Player %s" %(player_index + 1))
	sprite.set_material(sprite.get_material().duplicate(true))


enum CONTROLS {
	B = 1
	LEFT = 14
	RIGHT = 15
}
var just_pressed_b: bool = false
var just_pressed_left: bool = false
var just_pressed_right: bool = false

func _process(_delta):
	if (ready == false):
		change_skin(0)
		
		if (Input.is_joy_button_pressed(player_index, CONTROLS.LEFT)):
			if (just_pressed_left == false):
				change_skin(-1)
				just_pressed_left = true
		else:
			just_pressed_left = false
		
		if (Input.is_joy_button_pressed(player_index, CONTROLS.RIGHT)):
			if (just_pressed_right == false):
				change_skin(1)
				just_pressed_right = true
		else:
			just_pressed_right = false
	else:
		if (Input.is_joy_button_pressed(player_index, CONTROLS.B)):
			if (just_pressed_b == false):
				unready()
				just_pressed_b = true
		else:
			just_pressed_b = false

func ready_up():
	global.remove_skin(skin_index)
	label.set_text("Ready")


func unready():
	ready = false
	global.add_skin(skin_index)
	label.set_text("Player %s" %(player_index + 1))


func change_skin(dir: int) -> void:
	skin_select = global.wrap(skin_select + dir, 0, global.skins_available-1)
	skin_index = global.skins_available_array[skin_select]
	sprite.material.set_shader_param("row", skin_index)


