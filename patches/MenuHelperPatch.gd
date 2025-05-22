const script_path = "res://menus/MenuHelper.gd"

static func process(code: String) -> String:
	var output: String = ""
	var code_lines: Array = code.split("\n")
	var code_index: int = 0

	# # #

	code_index = code_lines.find("""extends CanvasLayer""")
	if code_index >= 0:
		code_lines.insert(code_index + 1, _get_replacement_line("helpers"))

	code_index = code_lines.find("""func level_up(character_or_tape: Resource):""")
	if code_index >= 0:
		code_lines.insert(code_index - 1, _get_replacement_line("func_level_up_amount"))
	
	code_index = code_lines.find("""func consume_item(item: BaseItem, amount: int = 1, show_msg: bool = true) -> bool:""")
	if code_index >= 0:
		code_lines.insert(code_index - 1, _get_replacement_line("func_show_stack_box"))

	# # #

	for line in code_lines:
		output += line + "\n"

	return output

static func _get_replacement_line(block: String) -> String:
	var code_blocks: Dictionary = {}

	code_blocks["helpers"] = """
const CharacterHelper = preload("res://mods/cb_inventory_plus/helpers/CharacterHelper.gd")
const MonsterTapeHelper = preload("res://mods/cb_inventory_plus/helpers/MonsterTapeHelper.gd")
"""
	
	code_blocks["func_level_up_amount"] = """
func level_up_amount(character_or_tape: Resource, amount: int):
	var exp_yield: int = 0
	if character_or_tape is Character:
		var character = CharacterHelper.new(character_or_tape)
		exp_yield = character.get_exp_to_reach_level(amount)
	elif character_or_tape is MonsterTape:
		var tape = MonsterTapeHelper.new(character_or_tape)
		exp_yield = tape.get_exp_to_reach_grade(amount)
	
	var menu = scenes.GainExpMenu.instance()
	menu.whitelist = [character_or_tape]
	menu.exp_yield = exp_yield
	menu.loot_table = null
	menu.bypass_upgrade = character_or_tape is MonsterTape
	add_child(menu)
	yield(menu.run_menu(), "completed")
	menu.queue_free()
"""

	code_blocks["func_show_stack_box"] = """
func show_stack_box(item: BaseItem, max_value: int = 100, min_value: int = 1) -> int:
	var menu = load("res://mods/cb_inventory_plus/menus/inventory/StackBox.tscn").instance()
	menu.item = item
	menu.min_value = min_value
	menu.max_value = max_value
	add_child(menu)
	var result = yield(menu.run_menu(), "completed")
	menu.queue_free()
	return result
"""

	return code_blocks[block]
