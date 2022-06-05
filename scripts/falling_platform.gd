extends KinematicBody2D

onready var sprite = get_node("AnimatedSprite")

var velocity: Vector2 = Vector2.ZERO
var initial_pos: Vector2
var fall_speed: int = 90
var raise_speed: int = 40
var falling: bool = false
var timer: int = 0
var time: int = 20


func _ready():
	initial_pos.y = global_position.y + 1


func _physics_process(_delta):
	if (falling):
		timer = time
	
	if (timer > 0):
		timer -= 1
	else:
		timer = 0
	
	if (timer > 0):
		velocity.y = fall_speed
		sprite.play("spin")
	else:
		if (global_position.y > initial_pos.y):
			velocity.y = -raise_speed
		else:
			global_position.y = initial_pos.y
			sprite.play("default")
	
	var _d = move_and_slide(velocity, Vector2.UP)


func _on_HitBox_area_entered(_area):
	falling = true


func _on_HitBox_area_exited(_area):
	falling = false
