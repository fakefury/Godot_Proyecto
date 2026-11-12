extends TextureButton

func _ready():
	hide()
	
	#conecta el boton al iniciar
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

func _on_pressed():
	print("¡Clic detectado! Intentando reiniciar...") 
	get_tree().reload_current_scene()
