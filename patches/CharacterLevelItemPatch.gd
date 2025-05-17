static func path() -> String:
	return "res://data/item_scripts/CharacterLevelItem.gd"

static func process(code: String) -> String:
	var output: String = ""
	var code_lines: Array = code.split("\n")
	var code_index: int = 0

	# # #

	code_index = code_lines.find("""func _use_in_world(_node, _context, character):""")
	if code_index >= 0:
		code_lines.insert(code_index - 1, _get_replacement_line("func_custom_use_menu"))
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
	if not arg:
		return null

	assert (arg is Character)
	if not (arg is Character):
		return null
		
	var max_value = min(SaveState.max_level - arg.level, value)
	var amount = yield(MenuHelper.show_stack_box(self, max_value), "completed")
	if not amount:
		return null
	
	return { "character": arg, "amount": amount, }
"""

	code_blocks["func_use_in_world"] = """
func _use_in_world(_node, _context, arg):
	assert (SaveState.inventory.has_item(self, arg["amount"]))
	yield(MenuHelper.level_up_amount(arg["character"], arg["amount"]), "completed")
	return MenuHelper.consume_item(self, arg["amount"], false)
"""
	return code_blocks[block]
