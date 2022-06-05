extends StaticBody2D

onready var sprite = get_node("AnimatedSprite")
var destroyed: bool = false


func _process(_delta):
	if (destroyed):
		sprite.play("destroyed")
	
	if (sprite.frame == 4):
		queue_free()


func _on_HitBox_area_entered(area):
	if (area.parent is Player):
		if (area.parent.state == area.parent.STATE.ROLL):
			destroyed = true
