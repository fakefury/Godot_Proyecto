extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var ray_suelo: RayCast2D = $RaySuelo
@onready var ray_frente: RayCast2D = $RayFrente


# ----------------------------------------
# MOVIMIENTO
# ----------------------------------------

var speed_base: float = 100.0
var speed_actual: float = 100.0

var is_moving: bool = true


# ----------------------------------------
# VIDA
# ----------------------------------------

var health: int = 1


func _ready() -> void:

	# Grupo para recibir daño
	add_to_group("enemigos")

	# Grupo para hacer daño al jugador
	add_to_group("damage")

	print("[LOBO] Registrado en grupo enemigos")


func _physics_process(delta: float) -> void:

	# Gravedad
	if not is_on_floor():
		velocity.y += get_gravity().y * delta


	# Animaciones
	if not is_on_floor():

		animated_sprite_2d.animation = "jump"

	elif abs(velocity.x) > 1:

		animated_sprite_2d.animation = "running"

	else:

		animated_sprite_2d.animation = "idle"


	move_character()
	detect_turn_around()

	move_and_slide()


func move_character() -> void:

	if is_moving:
		velocity.x = speed_actual
	else:
		velocity.x = -speed_actual


func detect_turn_around() -> void:

	var llego_al_borde = not ray_suelo.is_colliding() and is_on_floor()

	var choco_con_pared = is_on_wall()

	var obstaculo_al_frente = ray_frente.is_colliding()


	if llego_al_borde or choco_con_pared or obstaculo_al_frente:

		is_moving = !is_moving

		scale.x = -scale.x


# ----------------------------------------
# RALENTIZACIÓN
# ----------------------------------------

func aplicar_ralentizacion(porcentaje: float, tiempo: float) -> void:

	speed_actual = speed_base * porcentaje

	# Efecto visual
	modulate = Color(0.5, 0.7, 1.0)

	await get_tree().create_timer(tiempo).timeout

	# Restaurar velocidad
	speed_actual = speed_base

	# Restaurar color
	modulate = Color.WHITE


# ----------------------------------------
# DAÑO
# ----------------------------------------

func take_damage(damage_amount: int) -> void:

	print(
		"[LOBO] Recibió ",
		damage_amount,
		" de daño. Vida antes: ",
		health
	)

	health -= damage_amount

	print(
		"[LOBO] Vida después: ",
		health
	)


	if health <= 0:
		_die()


# ----------------------------------------
# MUERTE
# ----------------------------------------

func _die() -> void:

	print("[LOBO] ¡Murió por daño!")

	queue_free()
