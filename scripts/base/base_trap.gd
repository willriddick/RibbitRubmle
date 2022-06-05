extends Node2D
class_name BaseTrap

export var damage: int = 1
onready var hit_box = get_node("HitBox/CollisionShape2D")


func _on_HitBox_area_entered(area):
	if (area.parent is Player):
		area.parent.hurt(damage)
	hit_box.set_deferred("disabled", true)
	yield(get_tree().create_timer(0.01), "timeout")
	hit_box.set_deferred("disabled", false)
