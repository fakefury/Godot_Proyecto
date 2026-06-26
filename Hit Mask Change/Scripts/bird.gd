extends CharacterBody2D

const SPEED = 150
var direction = 1
var start_y = 0.0
var health = 1
var can_drop = true

@onready var ray_front = $RayFrente
@onready var ray_down = $RayAbajo

var rock_scene = preload("res://Escenas/roca.tscn")


func _ready():
	start_y = global_position.y
	add_to_group("damage")


func _physics_process(delta):
	# Mantener altura fija
	global_position.y = start_y
	velocity.y = 0

	# Girar al detectar pared
	if ray_front.is_colliding():
		direction *= -1
		ray_front.target_position.x = abs(ray_front.target_position.x) * direction
		ray_front.force_raycast_update()

	# --- SECCIÓN DE DIAGNÓSTICO ---
	if ray_down.is_colliding():
		var body = ray_down.get_collider()
		print("¡El rayo detectó algo llamado: ", body.name) # Nos dice qué está tocando

		if body.name == "Area2D":
			print("¡Detectó al Player! can_drop es igual a: ", can_drop)
			if can_drop:
				drop_rock()
	# ------------------------------

	# Movimiento
	velocity.x = SPEED * direction
	move_and_slide()

	# Girar sprite
	$AnimatedSprite2D.flip_h = direction == -1


func drop_rock():
	var rock = rock_scene.instantiate()
	get_parent().add_child(rock)
	rock.global_position = global_position

	can_drop = false
	await get_tree().create_timer(2.0).timeout
	can_drop = true


func take_damage(damage_amount):
	health -= damage_amount

	if health <= 0:
		_die()


func _die():
	queue_free()
