extends CharacterBody2D 

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D 

@onready var ray_suelo: RayCast2D = $RaySuelo
@onready var ray_frente: RayCast2D = $RayFrente

const SPEED = 100.0 
var is_moving = true 
var health = 1

func _ready(): 
	self.add_to_group("damage")
	
func move_character():
	velocity.x = SPEED if is_moving else -SPEED 
		
func _physics_process(delta: float) -> void:
	if not is_on_floor(): 
		velocity.y += get_gravity().y * delta 
		
	if not is_on_floor():
		animated_sprite_2d.animation = "jump" 
	elif abs(velocity.x) > 1:
		animated_sprite_2d.animation = "running" 
	else: 
		animated_sprite_2d.animation = "idle" 
		
	move_character() 
	detect_turn_around() 
	move_and_slide() 
			
func detect_turn_around(): 
	var llego_al_borde = not ray_suelo.is_colliding() and is_on_floor()
	var choco_con_pared = is_on_wall()
	var obstaculo_al_frente = ray_frente.is_colliding()
	
	if llego_al_borde or choco_con_pared or obstaculo_al_frente:
		is_moving = !is_moving 
		scale.x = -scale.x
		
func take_damage(damage):
	health -= damage
	if health <= 0:
		_die()

func _die():
	queue_free()
