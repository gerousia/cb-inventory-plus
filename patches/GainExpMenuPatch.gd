const script_path = "res://menus/gain_exp/GainExpMenu.gd"
const cached_script = preload("res://menus/gain_exp/GainExpMenu.gd")

static func process(code: String) -> String:
	var output: String = ""
	var code_lines: Array = code.split("\n")
	var code_index: int = 0

	# # #

	code_index = code_lines.find("""var started: bool = false""")
	if code_index >= 0:
		code_lines.insert(code_index + 1, _get_replacement_line("add_variable"))

	code_index = code_lines.find("""func _init():""")
	if code_index >= 0:
		code_lines.insert(code_index + 1, _get_replacement_line("disable_variable"))

	#while code_lines.has("""		if TAPES_UPGRADE_ONLY_ONCE:"""):
	code_index = code_lines.find("""		if TAPES_UPGRADE_ONLY_ONCE:""") # 1
	if code_index >= 0:
		code_lines[code_index] = _get_replacement_line("modify_statement")

	code_index = code_lines.find("""		if TAPES_UPGRADE_ONLY_ONCE:""") # 2
	if code_index >= 0:
		code_lines[code_index] = _get_replacement_line("modify_statement")

	# # #

	for line in code_lines:
		output += line + "\n"

	return output

static func _get_replacement_line(block: String) -> String:
	var code_blocks: Dictionary = {}

	code_blocks["add_variable"] = """
var bypass_upgrade: bool
"""

	code_blocks["disable_variable"] = """
	bypass_upgrade = false
"""
	
	code_blocks["modify_statement"] = """
		if TAPES_UPGRADE_ONLY_ONCE and not bypass_upgrade:
"""

	return code_blocks[block]
