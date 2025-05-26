const script_path = "res://data/item_scripts/ReodorantItem.gd"
const cached_path = preload("res://data/item_scripts/ReodorantItem.gd")

static func process(code: String) -> String:
	var output: String = ""
	var code_lines: Array = code.split("\n")
	var code_index: int = 0

	# # #

	code_index = code_lines.find("""func _use_in_world(_node, _context, _arg):""")
	if code_index >= 0:
		var block_size = 10
		for index in range(block_size - 1, -1, -1):
			code_lines.remove(code_index + index)
		code_lines.insert(code_index - 1, _get_replacement_line("func_custom_use_menu"))
		code_lines.insert(code_index, _get_replacement_line("func_use_in_world"))

	# # #

	for line in code_lines:
		output += line + "\n"

	return output

static func _get_replacement_line(block: String) -> String:
	var code_blocks: Dictionary = {}
	
	code_blocks["func_custom_use_menu"] = """
func custom_use_menu(_node, _context_kind: int, _context, _arg = null):
	if _arg != null:
		return _arg
		
	var amount = yield(MenuHelper.show_stack_box(self), "completed")
	if not amount:
		return null
	
	return { "amount": amount }
"""

	code_blocks["func_use_in_world"] = """
func _use_in_world(_node, _context, arg):
	assert (SaveState.inventory.has_item(self, arg["amount"]))
	WorldSystem.reodorant_timer += arg["amount"] * duration
	
	if cutscene:
		var sc = cutscene.instance()
		SceneManager.current_scene.add_child(sc)
		sc.free_cutscene_on_exit = true
		sc.run()
	
	return MenuHelper.consume_item(self, arg["amount"], false)
"""
	return code_blocks[block]
