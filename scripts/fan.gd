extends Node2D


onready var sprite = get_node("AnimatedSprite")
onready var hit_box = get_node("HitBox/CollisionShape2D")
onready var audio = get_node("Audio")
export var speed: int = 200 

enum DIR {
	UP
	DOWN
	LEFT
	RIGHT
}
export(DIR) var facing_dir: int


func _ready():
	match facing_dir:
		DIR.UP:
			global_rotation_degrees = 0
		DIR.DOWN:
			global_rotation_degrees = 180
		DIR.RIGHT:
			global_rotation_degrees = 90
		DIR.LEFT:
			global_rotation_degrees = 270


func _on_HitBox_area_entered(area):
	var _inst = area.parent
	if (_inst is Player && _inst.state != _inst.STATE.ROLL):
		global.play_audio(audio, 1, -0.1, 0.1)
		
		match facing_dir:
			DIR.UP:
				_inst.velocity.y = -speed
			DIR.DOWN:
				_inst.velocity.y = speed
			DIR.RIGHT:
				_inst.velocity = Vector2(speed, -speed/1.75)
			DIR.LEFT:
				_inst.velocity = Vector2(-speed, -speed/1.75)
	
	hit_box.set_deferred("disabled", true)
	yield(get_tree().create_timer(0.01), "timeout")
	hit_box.set_deferred("disabled", false)


func _on_AnimatedSprite_animation_finished():
	sprite.play("default")
