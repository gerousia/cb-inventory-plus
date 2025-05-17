static func patch():
	var script_path = "res://data/Character.gd"
	var patched_script = preload("res://data/Character.gd")

	if !patched_script.has_source_code():
		var file: File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines: Array = patched_script.source_code.split("\n")
	var code_index: int = 0
	
	# # #
	
	code_index = code_lines.find("""func get_exp_to_next_level() -> int:""")
	if code_index >= 0:
		code_lines.insert(code_index - 1, get_code("func_get_exp_to_reach_level"))

	# # #

	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"

	var err = patched_script.reload(true)
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return

static func get_code(block: String) -> String:
	var code_blocks: Dictionary = {}
	
	code_blocks["func_get_exp_to_reach_level"] = """
func get_exp_to_reach_level(amount: int) -> int:
	var exp_points = 0
	var target_level = int(min(MAX_MAX_LEVEL, level + amount))
	for _level in range(level, target_level):
		exp_points += BattleFormulas.get_exp_to_next_level(_level, exp_gradient, exp_base_level)
	return exp_points
"""

	return code_blocks[block]
