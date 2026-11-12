extends CharacterBody2D

@onready var roca: AnimatedSprite2D = $Sprite2D

var damage = 1

func _ready():
	
	roca.play("subir")
	await get_tree().create_timer(3.0).timeout
	
	roca.play("bajar")
	await roca.animation_finished

	queue_free()


func _on_area_2d_area_entered(area: Area2D):
	print("SE DETECTÓ ALGO")
	print(area.name)
	print(area.get_parent().name)

	if area.get_parent().is_in_group("damage"):
		print("ENEMIGO ENCONTRADO")
		area.get_parent().take_damage(damage)
