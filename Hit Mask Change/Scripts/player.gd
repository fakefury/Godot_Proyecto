extends CharacterBody2D

@onready var animatedSprite2D: AnimatedSprite2D = $Sprite/AnimatedSprite2D
@onready var body: Node2D = $Sprite

const SPEED = 200.0
const JUMP_VELOCITY = -650.0
var health = 6
var invincible = false
var invincibility_time = 1.0
var dead = false
var knockback_force = 300.0
var knockback_time = 0.3
var is_knockback = false
var direction

@export var roca_scene: PackedScene
var using_ability = false
var submerged = false

func _physics_process(delta: float) -> void:
	
	if dead:
		return
		
	if using_ability:
		move_and_slide()
		return
	
	if submerged:
		move_and_slide()
		return		
		
	if not is_knockback:
		if not is_on_floor():
			velocity += get_gravity() * delta
			animatedSprite2D.play("jump")
		else:
			if velocity.x > 1 or velocity.x < -1:
				animatedSprite2D.play("running")
			else:
				animatedSprite2D.play("idle")
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
		body.scale.x = 1
	elif direction == -1.0:
		body.scale.x = -1

	if Input.is_action_just_pressed("roca"):
		spawn_roca()

func blink():
	for i in range(6):
		body.visible = false
		await get_tree().create_timer(0.05).timeout
		body.visible = true
		await get_tree().create_timer(0.05).timeout
		
func die():
	animatedSprite2D.play("dead")
	await animatedSprite2D.animation_finished
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
	
	animatedSprite2D.play("hit")
	await get_tree().create_timer(0.1).timeout
	
	set_collision_mask_value(2, false)
	blink()
	
	await get_tree().create_timer(knockback_time).timeout
	is_knockback = false
	
	await get_tree().create_timer(invincibility_time).timeout
	invincible = false
	
	set_collision_mask_value(2, true)

func _damaged(area: Area2D):
	if area.is_in_group("damage"):
		damaged(area)

func spawn_roca():
	
	using_ability = true
	
	velocity = Vector2.ZERO
	
	var roca = roca_scene.instantiate()
	
	var offset = 40
	
	if body.scale.x < 0:
		roca.global_position = global_position + Vector2(-offset, 0)
	else:
		roca.global_position = global_position + Vector2(offset, 0)
	
	get_parent().add_child(roca)
	
	#animation.play
	
	await get_tree().create_timer(0.4).timeout
	
	using_ability = false
