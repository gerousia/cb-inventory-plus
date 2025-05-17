#extends BaseItem
#
#func get_rarity():
#	return Rarity.RARITY_RARE
#
#func get_use_options(_node, _context_kind: int, _context) -> Array:
#	return [{"label": "ITEM_USE_ON_SUBMENU", "arg": null}]
#
## # # REFACTORED # # #
#func custom_use_menu(_node, _context_kind: int, _context, arg = null):
#	if arg != null:
#		return arg
#
#	var tape = yield(MenuHelper.show_choose_tape_menu(SaveState.party.get_tapes(), Bind.new(self, "_tape_filter")), "complete")
#	assert (tape is MonsterTape)
#	if not (tape is MonsterTape):
#		return false
#
#	var max_value = min(MonsterTape.MAX_TAPE_GRADE - tape.grade, value)
#	var amount = yield(MenuHelper.show_stack_box(self, max_value), "completed")
#	if amount == null or amount <= 0:
#		return false
#
#	return { "tape": tape, "amount": amount }
## # # # # #
#
#func _tape_filter(tape: MonsterTape) -> bool:
#	return tape.grade < MonsterTape.MAX_TAPE_GRADE
#
## # # REPLACED # # #
## func _use_in_world(_node, _context, arg):
## 	assert (arg is MonsterTape)
## 	if not (arg is MonsterTape):
## 		return false
## 	yield(MenuHelper.level_up(arg), "completed")
## 	return true
## # # # # #
#
#func _use_in_world(_node, _context, arg):
#	assert (SaveState.inventory.has_item(self, arg["amount"]))
#	yield(MenuHelper.level_up_amount(arg["tape"], arg["amount"]), "completed")
#	return MenuHelper.consume_item(self, arg["amount"], false)
