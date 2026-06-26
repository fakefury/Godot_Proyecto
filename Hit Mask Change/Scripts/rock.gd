extends CharacterBody2D

const FALL_SPEED = 300
var damage = 1

func _physics_process(delta):

	velocity.y = FALL_SPEED
	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()

		if body.has_method("take_damage"):
			body.take_damage(damage)

		queue_free()
