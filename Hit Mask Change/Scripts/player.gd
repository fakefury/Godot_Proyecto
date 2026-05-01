extends CharacterBody2D

@onready var character: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 200.0
const JUMP_VELOCITY = -650.0
var health = 3
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
var rocas_activas = []

func _physics_process(delta: float) -> void:
	
	if dead:
		return
	
	if Input.is_action_just_pressed("sumergir") and is_on_floor():
		toggle_submerge()
		return
	
	if using_ability:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if submerged:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if not is_knockback:
		
		if not is_on_floor():
			velocity += get_gravity() * delta
			character.play("jump")
		
		else:
			if velocity.x > 1 or velocity.x < -1:
					character.play("running")
			else:
				if character.animation != "salir":
					character.play("idle")
	
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
		character.scale.x = 1
	
	elif direction == -1.0:
		character.scale.x = -1

	#if Input.is_action_just_pressed("roca"):
	#	spawn_roca()

func blink():
	for i in range(6):
		character.visible = false
		await get_tree().create_timer(0.05).timeout
		character.visible = true
		await get_tree().create_timer(0.05).timeout
		
func die():
	character.play("dead")
	await character.animation_finished
	queue_free()
		
func damaged(body:Node2D):
	
	if invincible:
		return
	
	health -= 1
	
	if health <= 0:
		dead = true
		die()
		return
	
	invincible = true
	is_knockback = true
	
	var dir = sign(global_position.x - body.global_position.x)
	velocity.x = dir * knockback_force
	velocity.y = -400
	
	character.play("hit")
	await get_tree().create_timer(0.1).timeout
	
	set_collision_mask_value(3, false)
	set_collision_mask_value(2, false)
	blink()
	
	await get_tree().create_timer(knockback_time).timeout
	is_knockback = false
	
	await get_tree().create_timer(invincibility_time).timeout
	if !submerged:
		invincible = false
		set_collision_mask_value(3, true)
		set_collision_mask_value(2, true)

func _damaged(body: Node2D):
	if body.is_in_group("damage"):
		damaged(body)

func spawn_roca():
	
	if not is_on_floor():
		return

	using_ability = true
	
	velocity = Vector2.ZERO
	
	var roca = roca_scene.instantiate()
	
	var offset = 40
	
	if character.scale.x < 0:
		roca.global_position = global_position + Vector2(-offset, 0)
	else:
		roca.global_position = global_position + Vector2(offset, 0)
	
	get_parent().add_child(roca)
	
	rocas_activas.append(roca)
	
	if rocas_activas.size() > 3:
		
		var roca_vieja = rocas_activas[0]
		
		roca_vieja.queue_free()
		
		rocas_activas.remove_at(0)
	
	character.play("pisar")
	
	
	await get_tree().create_timer(0.4).timeout
	
	
	using_ability = false

func toggle_submerge():
	
	submerged = !submerged
	
	if submerged:
		
		velocity = Vector2.ZERO
		
		character.play("sumergir")
		
		set_collision_layer_value(2, false)
		set_collision_mask_value(3, false)
		set_collision_mask_value(2, false)
		$Area2D.set_collision_mask_value(3, false)
		
		invincible = true
	
	else:
		using_ability = true
		
		character.play("salir")
		await character.animation_finished
		
		using_ability = false
		
		set_collision_layer_value(2, true)
		set_collision_mask_value(3, true)
		set_collision_mask_value(2, true)
		$Area2D.set_collision_mask_value(3, true)
		
		invincible = false
