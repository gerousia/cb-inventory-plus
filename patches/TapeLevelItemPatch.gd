static func patch():
	var script_path = "res://data/item_scripts/TapeLevelItem.gd"
	var patched_script: GDScript = preload("res://data/item_scripts/TapeLevelItem.gd")

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
	
	code_index = code_lines.find("""func custom_use_menu(_node, _context_kind: int, _context, arg = null):""")
	if code_index >= 0:
		code_lines.remove(code_index + 5)
		code_lines.remove(code_index + 4)
		code_lines.remove(code_index + 3)
		code_lines.remove(code_index + 2)
		code_lines.remove(code_index + 1)
		code_lines.remove(code_index)
		code_lines.insert(code_index, get_code("func_custom_use_menu"))
		
	code_index = code_lines.find("""func _use_in_world(_node, _context, arg):""")
	if code_index >= 0:
		code_lines.remove(code_index + 5)
		code_lines.remove(code_index + 4)
		code_lines.remove(code_index + 3)
		code_lines.remove(code_index + 2)
		code_lines.remove(code_index + 1)
		code_lines.remove(code_index)
		code_lines.insert(code_index, get_code("func_use_in_world"))

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
	
	code_blocks["func_custom_use_menu"] = """
func custom_use_menu(_node, _context_kind: int, _context, arg = null):
	if arg != null:
		return arg

	var tape = yield(MenuHelper.show_choose_tape_menu(SaveState.party.get_tapes(), Bind.new(self, "_tape_filter")), "completed")
	assert (tape is MonsterTape)
	if not (tape is MonsterTape):
		return false

	var max_value = min(MonsterTape.MAX_TAPE_GRADE - tape.grade, value)
	var amount = yield(MenuHelper.show_stack_box(self, max_value), "completed")
	if amount == null or amount <= 0:
		return false

	return { "tape": tape, "amount": amount }
"""

	code_blocks["func_use_in_world"] = """
func _use_in_world(_node, _context, arg):
	assert (SaveState.inventory.has_item(self, arg["amount"]))
	yield(MenuHelper.level_up_amount(arg["tape"], arg["amount"]), "completed")
	return MenuHelper.consume_item(self, arg["amount"], false)
"""
	return code_blocks[block]
