extends Camera2D

var target_x: int = 0
var target_y: int = 0

var d_lerp_speed: float = 0.05
var lerp_speed: float = d_lerp_speed

var shake_magnitude: Vector2 = Vector2.ZERO
var shake_remain: Vector2 = Vector2.ZERO
var shake_length: int = 0


func _process(_delta):
	if (shake_length > 0):
		set_global_position(
			Vector2(get_global_position().x + rand_range(-shake_remain.x, shake_remain.x),
					get_global_position().y + rand_range(-shake_remain.y, shake_remain.y)))
		
		shake_remain.x = max(0, shake_remain.x - ((1 / float(shake_length)) * shake_magnitude.x))
		shake_remain.y = max(0, shake_remain.y - ((1 / float(shake_length)) * shake_magnitude.y))
		shake_length -= 1
	else:
		shake_length = 0
	
	
	var x = lerp(get_global_position().x, target_x, lerp_speed)
	var y = lerp(get_global_position().y, target_y, lerp_speed)
	set_global_position(Vector2(x, y))


func set_screenshake(magnitude: Vector2, length: int):
	shake_magnitude = magnitude
	shake_remain = magnitude
	shake_length = length
