extends CharacterBody2D

@onready var roca: Sprite2D = $Sprite2D

var damage = 1
signal attack(damage)

func _on_area_2d_area_entered(area: Area2D):
	print("se detecto algo")
	if area.is_in_group("damage"):
		area.take_damage(damage)
