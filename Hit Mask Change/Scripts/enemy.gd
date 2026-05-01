extends CharacterBody2D 

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D 
@onready var ray: RayCast2D = $RayCast2D 

const SPEED = 100.0 
var is_moving = true 

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
	else: animated_sprite_2d.animation = "idle" 
		
	move_character() 
	detect_turn_around() 
	move_and_slide() 
			
func detect_turn_around(): 
	if not ray.is_colliding() and is_on_floor(): 
		is_moving = !is_moving 
		scale.x = -scale.x
