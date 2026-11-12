extends Node

var _current_level: int = 1

var current_level: int:
	get:
		return _current_level
	set(value):
		_current_level = value
		data_game["current_level"] = value
		save_game()


var data_game: Dictionary = {
	"current_level": 1
}


func _ready() -> void:
	load_game()


func save_game() -> void:
	var file := FileAccess.open("user://data.save", FileAccess.WRITE)

	if file:
		var json_string := JSON.stringify(data_game)
		file.store_line(json_string)
		file.close()


func load_game() -> void:
	if not FileAccess.file_exists("user://data.save"):
		return

	var file := FileAccess.open("user://data.save", FileAccess.READ)

	if file:
		var json_string := file.get_line()
		file.close()

		var data_json = JSON.parse_string(json_string)

		if data_json is Dictionary:
			_current_level = data_json.get("current_level", 1)
			data_game["current_level"] = _current_level
