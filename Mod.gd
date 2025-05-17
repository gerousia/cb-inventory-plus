extends ContentInfo

const PATCHES = [
	preload("res://mods/cb_inventory_plus/patches/MenuHelperPatch.gd"),
	preload("res://mods/cb_inventory_plus/patches/CharacterLevelItemPatch.gd"),
]

func _init(): # modified cat_modutils
	for patch in PATCHES:
		var script: GDScript = fetch(patch.path())
		var code: String = patch.process(read(script))
		write(script, code)

func fetch(path: String) -> GDScript:
	if not ResourceLoader.has_cached(path):
		push_error("Expected cached resource not found: %s" % path)
		return null
	return ResourceLoader.load(path, "GDScript") as GDScript

func read(script: GDScript) -> String:
	var err: int
	var source_code: String = ""

	if script.has_source_code():
		source_code = script.source_code
	else:
		var file: File = File.new()
		if not file.file_exists(script.resource_path):
			push_error("Expected file not found: %s" % script.resource_path)
			return ""
		err = file.open(script.resource_path, File.READ)
		if not err == OK:
			push_error("Failed to open file: %s" % script.resource_path)
			return ""
		source_code = file.get_as_text()
		file.close()

	return source_code

func write(script: GDScript, code: String) -> void:
	script.source_code = code
	var err: int = script.reload(true)
	if not err == OK:
		push_error("Failed to patch file: %s" % script.resource_path)
		return
