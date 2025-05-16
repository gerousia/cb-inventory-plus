#extends BaseItem
#
#func get_rarity():
#	return Rarity.RARITY_RARE
#
#func get_use_options(node, context_kind: int, context) -> Array:
#	if context_kind == ContextKind.CONTEXT_WORLD:
#		var result = []
#		var characters = SaveState.party.characters
#		for character in characters:
#			if character.partner_id != "" and not SaveState.party.is_partner_unlocked(character.partner_id):
#				continue
#			result.push_back({
#				"label": Loc.trgf("ITEM_USE_ON", character.pronouns, [character.name]), 
#				"disabled": character.level >= SaveState.max_level, 
#				"arg": character
#			})
#		return result
#	return .get_use_options(node, context_kind, context)
#
# # # NEW # # #
#func custom_use_menu(_node, _context_kind: int, _context, arg = null):
#	if not arg:
#		return null
#
#	assert (arg is Character)
#	if not (arg is Character):
#		return null
#
#	var max_value = min(SaveState.max_level - arg.level, self.value)
#	return { "character": arg, "amount": Bind.new(MenuHelper, "consume_item_stack", [self, max_value]) }
# # # # # #
#
## # # REPLACED # # #
##func _use_in_world(_node, _context, character):
##	yield(MenuHelper.level_up(character), "completed")
##	return true
## # # # # #
#
#func _use_in_world(_node, _context, arg):
#	return MenuHelper.level_up_amount(arg["character"], yield(arg["amount"].call_func(), "completed"))
