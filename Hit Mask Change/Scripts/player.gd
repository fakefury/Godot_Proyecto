extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -850.0
var health = 6
var invincible = false
var invincibility_time = 1.0
var dead = false
var knockback_force = 300.0
var knockback_time = 0.3
var is_knockback = false
var direction

func _physics_process(delta: float) -> void:
	
	if dead:
		return
		
	if not is_knockback:
		if not is_on_floor():
			velocity += get_gravity() * delta
			animated_sprite_2d.animation = "jump"
		else:
			if velocity.x > 1 or velocity.x < -1:
				animated_sprite_2d.animation = "running"
			else:
				animated_sprite_2d.animation = "idle"
	else:
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if not is_knockback:
		direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	if direction == 1.0:
		animated_sprite_2d.flip_h = false
	elif direction == -1.0:
		animated_sprite_2d.flip_h = true

func blink():
	for i in range(6):
		animated_sprite_2d.visible = false
		await get_tree().create_timer(0.05).timeout
		animated_sprite_2d.visible = true
		await get_tree().create_timer(0.05).timeout
		
func die():
	animated_sprite_2d.animation = "dead"
	await animated_sprite_2d.animation_finished
	queue_free()
		
func damaged(area):
	
	if invincible:
		return
	
	health -= 1
	
	if health <= 0:
		dead = true
		die()
		return
	
	invincible = true
	is_knockback = true
	
	var dir = sign(global_position.x - area.global_position.x)
	velocity.x = dir * knockback_force
	velocity.y = -400
	
	animated_sprite_2d.animation = "hit"
	await get_tree().create_timer(0.1).timeout
	
	set_collision_mask_value(2, false)
	blink()
	
	await get_tree().create_timer(knockback_time).timeout
	is_knockback = false
	
	await get_tree().create_timer(invincibility_time).timeout
	invincible = false
	
	if invincible == false and get_collision_mask_value(2) == false:
		_damaged(area)
		
func _damaged(area: Area2D):
	if area.is_in_group("damage"):
		damaged(area)
		
func _exit_body(area: Area2D):
	set_collision_mask_value(2, true)
