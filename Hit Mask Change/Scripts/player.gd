extends CharacterBody2D

@onready var character: AnimatedSprite2D = $AnimatedSprite2D

@onready var habilidad_u_icono = $"../CanvasLayer/Habilidad_U/Icono"
@onready var roca_no_flota = $RayCast2D
@onready var habilidad_i_icono = $"../CanvasLayer/Habilidad_I/Icono"
@onready var habilidad_o_icono = $"../CanvasLayer/Habilidad_O/Icono"

# Cooldown Labels
@onready var habilidad_u_label = $"../CanvasLayer/Habilidad_U/Cooldown"
@onready var habilidad_i_label = $"../CanvasLayer/Habilidad_I/Cooldown"
@onready var habilidad_o_label = $"../CanvasLayer/Habilidad_o/Cooldown"

# Corazones
@onready var corazon1 = $"../CanvasLayer/Corazon1"
@onready var corazon2 = $"../CanvasLayer/Corazon2"
@onready var corazon3 = $"../CanvasLayer/Corazon3"

# Para cambiar cuando se hace daño
@export var corazon_tierra: Texture2D
@export var corazon_hielo: Texture2D
@export var corazon_agua: Texture2D
@export var corazon_fuego: Texture2D
@export var corazon_aire: Texture2D
@export var corazon_hierro: Texture2D

@export var icono_u_tierra: Texture2D
@export var icono_u_hielo: Texture2D
@export var icono_u_agua: Texture2D
@export var icono_u_fuego: Texture2D
@export var icono_u_aire: Texture2D
@export var icono_u_hierro: Texture2D

@export var icono_i_tierra: Texture2D
@export var icono_i_hielo: Texture2D
@export var icono_i_agua: Texture2D
@export var icono_i_fuego: Texture2D
@export var icono_i_aire: Texture2D
@export var icono_i_hierro: Texture2D

@export var icono_o_tierra: Texture2D
@export var icono_o_hielo: Texture2D
@export var icono_o_agua: Texture2D
@export var icono_o_fuego: Texture2D
@export var icono_o_aire: Texture2D
@export var icono_o_hierro: Texture2D


const SPEED = 200.0
const ACCELERATION = 1200
const FRICTION = 1800
const JUMP_VELOCITY = -650.0
const COYOTE_TIME = 0.15
const JUMP_BUFFER_TIME = 0.15

var jump_buffer_timer = 0.0
var coyote_timer = 0.0

var health = 3
var invincible = false
var invincibility_time = 1.0
var dead = false

var knockback_force = 300.0
var knockback_time = 0.3
var is_knockback = false

var direction = 1
var ultima_direccion = 1


@export var roca_scene: PackedScene
@export var terremoto_scene: PackedScene

var using_ability = false
var submerged = false
var rocas_activas = []

var roca_cooldown = 5
var roca_cd_actual = 0.0

var sumergir_cooldown = 3
var sumergir_cd_actual = 0.0

var terremoto_cooldown = 10.0
var terremoto_cd_actual = 0.0

@export var tiempo_para_regenerar: float = 10.0
var regeneracion_timer: float = 0.0

var elemento_actual = "tierra"
var should_blink = false


func timer_blink() -> void:
	should_blink = true


func _physics_process(delta: float) -> void:

	# ----------------------------------------
	# REGENERACIÓN
	# ----------------------------------------

	if health < 3 and not dead:
		regeneracion_timer += delta

		if regeneracion_timer >= tiempo_para_regenerar:
			health += 1
			actualizar_corazones()
			regeneracion_timer = 0.0
	else:
		regeneracion_timer = 0.0


	# ----------------------------------------
	# COOLDOWNS
	# ----------------------------------------

	if roca_cd_actual > 0:
		roca_cd_actual -= delta

	if sumergir_cd_actual > 0:
		sumergir_cd_actual -= delta

	if terremoto_cd_actual > 0:
		terremoto_cd_actual -= delta


	# ----------------------------------------
	# UI - ROCA
	# ----------------------------------------

	if roca_cd_actual > 0:
		if habilidad_u_icono:
			habilidad_u_icono.modulate.a = 0.5

		if habilidad_u_label:
			habilidad_u_label.text = str(ceil(roca_cd_actual))
	else:
		if habilidad_u_icono:
			habilidad_u_icono.modulate.a = 1.0

		if habilidad_u_label:
			habilidad_u_label.text = ""


	# ----------------------------------------
	# UI - SUMERGIR
	# ----------------------------------------

	if sumergir_cd_actual > 0:
		if habilidad_i_icono:
			habilidad_i_icono.modulate.a = 0.5

		if habilidad_i_label:
			habilidad_i_label.text = str(ceil(sumergir_cd_actual))
	else:
		if habilidad_i_icono:
			habilidad_i_icono.modulate.a = 1.0

		if habilidad_i_label:
			habilidad_i_label.text = ""


	# ----------------------------------------
	# UI - TERREMOTO
	# ----------------------------------------

	if terremoto_cd_actual > 0:
		if habilidad_o_icono:
			habilidad_o_icono.modulate.a = 0.5

		if habilidad_o_label:
			habilidad_o_label.text = str(ceil(terremoto_cd_actual))
	else:
		if habilidad_o_icono:
			habilidad_o_icono.modulate.a = 1.0

		if habilidad_o_label:
			habilidad_o_label.text = ""


	if dead:
		return


	# ----------------------------------------
	# SUMERGIR
	# ----------------------------------------

	if Input.is_action_just_pressed("sumergir") and is_on_floor():
		usar_habilidad_i()
		return


	# ----------------------------------------
	# HABILIDAD EN USO
	# ----------------------------------------

	if using_ability:
		velocity = Vector2.ZERO
		move_and_slide()
		return


	# ----------------------------------------
	# JUGADOR SUMERGIDO
	# ----------------------------------------

	if submerged:
		velocity = Vector2.ZERO
		move_and_slide()
		return


	# ----------------------------------------
	# MOVIMIENTO
	# ----------------------------------------

	if not is_knockback:

		if is_on_floor():
			coyote_timer = COYOTE_TIME

			if velocity.x > 1 or velocity.x < -1:

				if character.animation != "running":
					character.play("running")

			else:

				if character.animation != "salir":

					if (!(character.animation == "idle") || !(character.animation == "blink")):

						if should_blink:
							character.play("blink")
							should_blink = false
						else:
							character.play("idle")

		else:
			coyote_timer = max(coyote_timer - delta, 0)

			velocity += get_gravity() * delta

			if character.animation != "jump":
				character.play("jump")

	else:
		velocity += get_gravity() * delta


	# ----------------------------------------
	# SALTO
	# ----------------------------------------

	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME

	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5


	# ----------------------------------------
	# DIRECCIÓN
	# ----------------------------------------

	if not is_knockback:

		direction = Input.get_axis("left", "right")

		if direction:

			# Guardamos la última dirección hacia la que caminó
			ultima_direccion = direction

			velocity.x = move_toward(
				velocity.x,
				direction * SPEED,
				ACCELERATION * delta
			)

		else:

			velocity.x = move_toward(
				velocity.x,
				0,
				FRICTION * delta
			)


	move_and_slide()


	# ----------------------------------------
	# GIRAR SPRITE
	# ----------------------------------------

	if ultima_direccion == 1:
		character.scale.x = 1

	elif ultima_direccion == -1:
		character.scale.x = -1


	# ----------------------------------------
	# HABILIDADES
	# ----------------------------------------

	if Input.is_action_just_pressed("roca"):
		usar_habilidad_u()

	if Input.is_action_just_pressed("terremoto"):
		usar_habilidad_o()


func actualizar_corazones():

	corazon1.visible = health >= 1
	corazon2.visible = health >= 2
	corazon3.visible = health >= 3

	match elemento_actual:

		"tierra":
			corazon1.texture = corazon_tierra
			corazon2.texture = corazon_tierra
			corazon3.texture = corazon_tierra


func actualizar_habilidades():

	match elemento_actual:

		"tierra":
			habilidad_u_icono.texture = icono_u_tierra
			habilidad_i_icono.texture = icono_i_tierra
			habilidad_o_icono.texture = icono_o_tierra

		"hielo":
			habilidad_u_icono.texture = icono_u_hielo
			habilidad_i_icono.texture = icono_i_hielo
			habilidad_o_icono.texture = icono_o_hielo

		"agua":
			habilidad_u_icono.texture = icono_u_agua
			habilidad_i_icono.texture = icono_i_agua
			habilidad_o_icono.texture = icono_o_agua

		"fuego":
			habilidad_u_icono.texture = icono_u_fuego
			habilidad_i_icono.texture = icono_i_fuego
			habilidad_o_icono.texture = icono_o_fuego

		"aire":
			habilidad_u_icono.texture = icono_u_aire
			habilidad_i_icono.texture = icono_i_aire
			habilidad_o_icono.texture = icono_o_aire

		"hierro":
			habilidad_u_icono.texture = icono_u_hierro
			habilidad_i_icono.texture = icono_i_hierro
			habilidad_o_icono.texture = icono_o_hierro


func blink():

	for i in range(6):

		character.visible = false
		await get_tree().create_timer(0.05).timeout

		character.visible = true
		await get_tree().create_timer(0.05).timeout


func _ready():

	actualizar_corazones()
	actualizar_habilidades()


func die():

	await get_tree().create_timer(1.0).timeout

	var boton = get_tree().current_scene.get_node_or_null(
		"CanvasLayer2/Boton_Reiniciar"
	)

	if boton != null:
		boton.show()
	else:
		print("Error: No se encontró el botón de reiniciar")

	queue_free()


func damaged(body: Node2D):

	if invincible:
		return

	health -= 1

	match elemento_actual:

		"tierra":
			elemento_actual = "hielo"

		"hielo":
			elemento_actual = "agua"

		"agua":
			elemento_actual = "fuego"

		"fuego":
			elemento_actual = "aire"

		"aire":
			elemento_actual = "hierro"

		"hierro":
			elemento_actual = "tierra"


	actualizar_corazones()
	actualizar_habilidades()


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


func usar_habilidad_u():

	match elemento_actual:

		"tierra":
			spawn_roca()


func usar_habilidad_i():

	match elemento_actual:

		"tierra":
			toggle_submerge()


func usar_habilidad_o():

	match elemento_actual:

		"tierra":
			crear_terremoto()


func _damaged(body: Node2D):

	if body.is_in_group("damage"):
		damaged(body)


func spawn_roca():

	if roca_cd_actual > 0:
		return

	if not is_on_floor() or not roca_no_flota.is_colliding():
		return

	roca_cd_actual = roca_cooldown
	using_ability = true

	velocity = Vector2.ZERO
	character.play("pisar")

	await get_tree().create_timer(0.4).timeout

	var roca = roca_scene.instantiate()
	var offset = 40

	if character.scale.x < 0:
		roca.global_position = global_position + Vector2(-offset, 0)
	else:
		roca.global_position = global_position + Vector2(offset, 0)

	get_parent().add_child(roca)

	if rocas_activas.size() > 0:
		rocas_activas.remove_at(0)

	await get_tree().create_timer(0.4).timeout

	using_ability = false


func toggle_submerge():

	if !submerged and sumergir_cd_actual > 0:
		return

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

		sumergir_cd_actual = sumergir_cooldown
		using_ability = true

		character.play("salir")

		await character.animation_finished

		using_ability = false

		set_collision_layer_value(2, true)
		set_collision_mask_value(3, true)
		set_collision_mask_value(2, true)

		$Area2D.set_collision_mask_value(3, true)

		invincible = false


func crear_terremoto():

	if terremoto_cd_actual > 0 or not is_on_floor() or using_ability:
		return

	if terremoto_scene == null:
		print("Error: No se ha asignado la escena 'terremoto_scene' en el Inspector")
		return

	terremoto_cd_actual = terremoto_cooldown
	using_ability = true
	velocity = Vector2.ZERO

	character.play("pisar")


	# ----------------------------------------
	# CREAR TERREMOTO
	# ----------------------------------------

	var terremoto = terremoto_scene.instantiate()

	# Distancia delante del jugador
	var distancia_terremoto = 60.0

	# Usamos la última dirección REAL del jugador
	# 1  = derecha
	# -1 = izquierda
	var direccion = ultima_direccion

	# Colocamos el terremoto delante del jugador
	terremoto.global_position = global_position + Vector2(
		direccion * distancia_terremoto,
		0
	)

	get_parent().add_child(terremoto)


	await get_tree().create_timer(0.5).timeout

	using_ability = false


func curar(cantidad: int = 1) -> void:

	if dead or health >= 3:
		return

	health = min(health + cantidad, 3)

	actualizar_corazones()
