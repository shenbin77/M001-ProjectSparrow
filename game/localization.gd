extends Node

var _data: Dictionary = {}
var _lang: String = "en"
var _path: String

func _ready() -> void:
	var root := ProjectSettings.globalize_path("res://").trim_suffix("/").get_base_dir() if OS.has_feature("editor") else OS.get_executable_path().get_base_dir()
	_path = root.path_join("data/localization.json")
	_load()

func _load() -> void:
	if not FileAccess.file_exists(_path):
		return
	var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(_path))
	if raw is Dictionary:
		_data = raw

func set_language(lang: String) -> void:
	if _data.has(lang):
		_lang = lang

func get_language() -> String:
	return _lang

func text(key: String) -> String:
	if _data.has(_lang) and _data[_lang].has(key):
		return _data[_lang][key]
	if _data.has("en") and _data["en"].has(key):
		return _data["en"][key]
	return key

func available_languages() -> Array:
	return _data.keys()
