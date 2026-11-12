extends Area2D

@export var duracion_terremoto: float = 2.0
@export var porcentaje_slow: float = 0.5
@export var tiempo_slow: float = 3.0
@export var dano: int = 1

# Para evitar aplicar el daño dos veces al mismo enemigo
var cuerpos_afectados: Array[Node] = []


func _ready() -> void:
	print("--- [TERREMOTO]: Habilidad instanciada en posición ", global_position, " ---")

	# IMPORTANTE:
	# Hacemos que el Area2D pueda detectar cuerpos de TODAS las capas.
	for i in range(1, 33):
		set_collision_mask_value(i, true)

	monitoring = true

	# Conectamos la señal
	body_entered.connect(_on_body_entered)

	# Esperamos un frame para detectar cuerpos que ya estaban dentro
	await get_tree().process_frame

	var cuerpos_iniciales = get_overlapping_bodies()

	print(
		"[TERREMOTO]: Cuerpos detectados al aparecer: ",
		cuerpos_iniciales.size()
	)

	for body in cuerpos_iniciales:
		_on_body_entered(body)

	# Duración del terremoto
	await get_tree().create_timer(duracion_terremoto).timeout

	print("--- [TERREMOTO]: Fin de duración. Eliminando nodo. ---")
	queue_free()


func _on_body_entered(body: Node2D) -> void:

	# Evitar procesar dos veces al mismo cuerpo
	if body in cuerpos_afectados:
		return

	# Ignorar al jugador
	if body is CharacterBody2D and body.has_method("usar_habilidad_o"):
		print("[TERREMOTO]: Jugador detectado. Ignorando.")
		return

	print("\n----------------------------------------")
	print("[TERREMOTO] CUERPO DETECTADO")
	print("Nombre: ", body.name)
	print("Clase: ", body.get_class())
	print("Grupos: ", body.get_groups())
	print("----------------------------------------")

	# Solo queremos afectar enemigos
	if not body.is_in_group("enemigos"):
		print("[TERREMOTO]: ", body.name, " no pertenece al grupo 'enemigos'.")
		return

	cuerpos_afectados.append(body)

	# ----------------------------------------
	# RALENTIZACIÓN
	# ----------------------------------------

	if body.has_method("aplicar_ralentizacion"):
		print(
			"[TERREMOTO]: Aplicando ralentización a ",
			body.name
		)

		body.aplicar_ralentizacion(
			porcentaje_slow,
			tiempo_slow
		)

	else:
		print(
			"[TERREMOTO]: ",
			body.name,
			" no tiene aplicar_ralentizacion()."
		)

	# ----------------------------------------
	# DAÑO
	# ----------------------------------------

	if body.has_method("take_damage"):
		print(
			"[TERREMOTO]: Aplicando ",
			dano,
			" de daño a ",
			body.name
		)

		body.take_damage(dano)

	else:
		print(
			"[TERREMOTO]: ",
			body.name,
			" NO tiene take_damage()."
		)

	print("----------------------------------------\n")
