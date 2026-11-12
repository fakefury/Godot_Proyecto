extends CharacterBody2D

const FALL_SPEED = 300
var damage = 1

func _ready():
	# Buena práctica: añadirlo al grupo "damage" igual que al pájaro
	add_to_group("damage")

func _physics_process(delta):
	# Aplicamos la velocidad de caída
	velocity.y = FALL_SPEED
	move_and_slide()

	# SOLUCIÓN 2: Si el proyectil detecta que tocó el suelo (o una pared), se destruye.
	if is_on_floor() or is_on_wall():
		queue_free()

	# Revisamos contra qué chocó mientras caía
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()

		# SOLUCIÓN 1: Preguntamos por el método correcto ("damaged")
		if body.has_method("damaged"):
			# Le pasamos "self" para que el Player sepa que ESTA roca lo golpeó
			# y así pueda calcular el knockback correctamente.
			body.damaged(self)
			queue_free() # Se destruye después de golpear al jugador
