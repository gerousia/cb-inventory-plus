static func path() -> String:
	return "res://data/item_scripts/TapeLevelItem.gd"

static func process(code: String) -> String:
	var output: String = ""
	var code_lines: Array = code.split("\n")
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
		code_lines.insert(code_index, _get_replacement_line("func_custom_use_menu"))
		
	code_index = code_lines.find("""func _use_in_world(_node, _context, arg):""")
	if code_index >= 0:
		code_lines.remove(code_index + 5)
		code_lines.remove(code_index + 4)
		code_lines.remove(code_index + 3)
		code_lines.remove(code_index + 2)
		code_lines.remove(code_index + 1)
		code_lines.remove(code_index)
		code_lines.insert(code_index, _get_replacement_line("func_use_in_world"))

	# # #

	for line in code_lines:
		output += line + "\n"

	return output

static func _get_replacement_line(block: String) -> String:
	var code_blocks: Dictionary = {}
	
	code_blocks["func_custom_use_menu"] = """
func custom_use_menu(_node, _context_kind: int, _context, arg = null):
	if arg != null:
		return arg

	var tape = yield(MenuHelper.show_choose_tape_menu(SaveState.party.get_tapes(), Bind.new(self, "_tape_filter")), "completed")
	if not tape or not tape is MonsterTape:
		return null

	var max_value = min(MonsterTape.MAX_TAPE_GRADE - tape.grade, value)
	var amount = yield(MenuHelper.show_stack_box(self, max_value), "completed")
	if amount == null or amount <= 0:
		return null

	return { "tape": tape, "amount": amount }
"""

	code_blocks["func_use_in_world"] = """
func _use_in_world(_node, _context, arg):
	assert (SaveState.inventory.has_item(self, arg["amount"]))
	yield(MenuHelper.level_up_amount(arg["tape"], arg["amount"]), "completed")
	return MenuHelper.consume_item(self, arg["amount"], false)
"""
	return code_blocks[block]
