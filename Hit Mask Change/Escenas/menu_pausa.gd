
extends Control

@onready var boton_continuar = $Centro/PanelContainer/VBoxContainer/Continuar
@onready var boton_reiniciar = $Centro/PanelContainer/VBoxContainer/Reiniciar
@onready var boton_salir = $Centro/PanelContainer/VBoxContainer/Salir

func _ready():
	hide()

	process_mode = Node.PROCESS_MODE_ALWAYS

	boton_continuar.pressed.connect(continuar)
	boton_reiniciar.pressed.connect(reiniciar)
	boton_salir.pressed.connect(salir)


func _input(event):
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		if visible:
			continuar()
		else:
			abrir_menu()

		get_viewport().set_input_as_handled()


func abrir_menu():
	show()
	get_tree().paused = true


func continuar():
	hide()
	get_tree().paused = false


func reiniciar():
	get_tree().paused = false
	get_tree().call_deferred("reload_current_scene")


func salir():
	get_tree().paused = false
	get_tree().quit()
