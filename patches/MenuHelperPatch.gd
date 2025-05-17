static func patch():
	var script_path = "res://menus/MenuHelper.gd"
	var patched_script: GDScript = preload("res://menus/MenuHelper.gd")

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
	
	code_index = code_lines.find("""func level_up(character_or_tape: Resource):""")
	if code_index >= 0:
		code_lines.insert(code_index - 1, get_code("func_level_up_amount"))
	
	code_index = code_lines.find("""func consume_item(item: BaseItem, amount: int = 1, show_msg: bool = true) -> bool:""")
	if code_index >= 0:
		code_lines.insert(code_index - 1, get_code("func_use_item_stack"))

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
	
	code_blocks["func_level_up_amount"] = """
func level_up_amount(character_or_tape: Resource, amount: int):
	var exp_yield: int = 0
	if character_or_tape is Character:
		exp_yield = character_or_tape.get_exp_to_reach_level(amount)
	elif character_or_tape is MonsterTape:
		exp_yield = character_or_tape.get_exp_to_reach_grade(amount)
	
	var menu = scenes.GainExpMenu.instance()
	menu.whitelist = [character_or_tape]
	menu.exp_yield = exp_yield
	menu.loot_table = null
	add_child(menu)
	yield(menu.run_menu(), "completed")
	menu.queue_free()
"""

	code_blocks["func_use_item_stack"] = """
func consume_item_stack(item: BaseItem, max_value: int = 100, min_value: int = 1) -> int:
	var menu = load("res://mods/cb_inventory_use_stack/menus/inventory/StackBox.tscn").instance()
	menu.item = item
	menu.min_value = min_value
	menu.max_value = max_value
	add_child(menu)
	var result = yield(menu.run_menu(), "completed")
	menu.queue_free()
	if result == null or not consume_item(item, result, false):
		return false
	else:
		item.consume_on_use = false # Override
	return result
"""

	return code_blocks[block]
