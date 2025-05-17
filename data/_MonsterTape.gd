#tool 
#extends Resource
#class_name MonsterTape
#
#signal name_changed
#
#const GROWABLE_STATS: Dictionary = {
#	max_hp = true, 
#	melee_attack = true, 
#	melee_defense = true, 
#	ranged_attack = true, 
#	ranged_defense = true, 
#	speed = true
#}
#const STAT_GROW_RATE: int = 2
#const MAX_TAPE_GRADE: int = 5
#const MAX_NAME_WIDTH: int = 220
#const MOVE_SLOTS_HARD_LIMIT: int = 16
#
#export (String) var name_override: String setget set_name_override
#export (Resource) var form setget set_form
#export (int) var grade: int = 0 setget set_grade
#export (int) var seed_value: int
#export (Array, Resource) var type_override: Array = [] setget set_type_override
#export (Array, Resource) var type_native: Array
#export (Array, Resource) var stickers: Array
#export (Dictionary) var stat_increments: Dictionary = {}
#export (int) var exp_points: int = 0
#export (bool) var favorite: bool = false
#
#var hp: Rational = Rational.new(1, 1)
#
#func _init():
#	if Engine.editor_hint:
#		return
#	type_override = []
#	stickers = []
#	stat_increments = {}
#
#func is_broken() -> bool:
#	return hp.compare(0) <= 0
#
#func _update_res_name():
#	resource_name = Datatables.get_db_key(form) + " Gr" + str(grade)
#	for type in type_override:
#		resource_name += " " + type.id
#
#func set_name_override(value: String):
#	name_override = value
#	emit_signal("name_changed")
#
#func set_form(value: Resource):
#	form = value
#	_update_res_name()
#
#func set_grade(value: int):
#	grade = value
#	_update_res_name()
#
#func set_type_override(value: Array):
#	type_override = value
#	_update_res_name()
#
#func get_name() -> String:
#	if name_override != "":
#		return name_override
#	return form.name if form else "???"
#
#func _to_string() -> String:
#	return get_name()
#
#func get_max_stickers() -> int:
#	var count = get_stat("move_slots")
#	if stickers.size() > count:
#		return stickers.size()
#	return count
#
#func get_stat(stat_name: String, modify_with_stickers: bool = true) -> int:
#	var stat_value = form.get(stat_name)
#	stat_value = grow_stat(stat_value, stat_name)
#	stat_value = modify_stat(stat_value, stat_name, modify_with_stickers)
#	if stat_name == "move_slots" and stat_value > MOVE_SLOTS_HARD_LIMIT:
#		return MOVE_SLOTS_HARD_LIMIT
#	return stat_value
#
#func grow_stat(stat_value: int, stat_name: String) -> int:
#	if GROWABLE_STATS.has(stat_name):
#		var grow_amount = STAT_GROW_RATE * int(min(grade, MAX_TAPE_GRADE))
#		stat_value = (100 + grow_amount) * stat_value / 100
#	return stat_value
#
#func modify_stat(stat_value: int, stat_name: String, modify_with_stickers: bool = true) -> int:
#	stat_value += stat_increments.get(stat_name, 0)
#	if not modify_with_stickers:
#		return stat_value
#
#	var multiplier = Rational.new(1, 1)
#	for sticker in stickers:
#		if sticker is StickerItem:
#			var move = sticker.get_modified_move()
#			if stat_name == "move_slots":
#				stat_value += move.get_attribute_stat(self, stat_name)
#			else:
#				multiplier.multiply_ip(move.get_stat_multiplier(self, stat_name))
#	return multiplier.to_int(stat_value)
#
#func has_moves() -> bool:
#	for sticker in stickers:
#		if sticker != null:
#			return true
#	return false
#
#func has_move(move: BattleMove) -> bool:
#	if move.base_move:
#		move = move.base_move
#	for sticker in stickers:
#		var sticker_move: BattleMove = sticker as BattleMove
#		if sticker is StickerItem:
#			sticker_move = sticker.get_modified_move()
#		if sticker_move and sticker_move.base_move:
#			sticker_move = sticker_move.base_move
#		if sticker_move == move:
#			return true
#	return false
#
#func get_move(index: int) -> BattleMove:
#	var sticker = get_sticker(index)
#	if sticker == null:
#		return null
#	return sticker.get_modified_move()
#
#func get_sticker(index: int) -> StickerItem:
#	if index >= stickers.size() or index < 0:
#		return null
#	var sticker = stickers[index]
#	if sticker == null:
#		return null
#	if sticker is BattleMove:
#		sticker = ItemFactory.create_sticker(sticker, null, BaseItem.Rarity.RARITY_COMMON)
#		stickers[index] = sticker
#	assert (sticker is StickerItem)
#	return sticker
#
#func peel_sticker(index: int, fix_overflow: bool = true) -> StickerItem:
#	var result = get_sticker(index)
#	if result == null:
#		return null
#	stickers[index] = null
#
#	if fix_overflow:
#		fix_slot_overflow()
#
#	return result
#
#func insert_sticker(index: int, sticker: StickerItem):
#	while index >= stickers.size():
#		stickers.push_back(null)
#	stickers[index] = sticker
#	fix_slot_overflow()
#
#func swap_stickers(i: int, j: int):
#	var max_stickers = get_max_stickers()
#	if i < 0 or j < 0 or i >= max_stickers or j >= max_stickers or i == j:
#		return
#	while i >= stickers.size() or j >= stickers.size():
#		stickers.push_back(null)
#	var tmp = stickers[i]
#	stickers[i] = stickers[j]
#	stickers[j] = tmp
#	fix_slot_overflow()
#
#func fix_slot_overflow(forced: bool = false):
#
#
#
#
#	var max_stickers = get_stat("move_slots")
#	if stickers.size() > max_stickers:
#		for i in range(stickers.size() - 1, - 1, - 1):
#			if stickers[i] == null:
#				stickers.remove(i)
#				if stickers.size() <= max_stickers:
#					return
#	while forced and stickers.size() > max_stickers:
#		stickers.remove(stickers.size() - 1)
#
#func sticker_can_be_replaced(index: int) -> bool:
#	if index < 0 or index >= stickers.size():
#		return false
#	if get_moves().size() < get_stat("move_slots"):
#		return true
#	var sticker = stickers[index]
#	if sticker is StickerItem:
#		var move = sticker.get_modified_move()
#		if move.get_attribute_stat(self, "move_slots") > 0:
#			return false
#	return true
#
#func get_moves() -> Array:
#	var result = []
#	for sticker in stickers:
#		if sticker is StickerItem:
#			result.push_back(sticker.get_modified_move())
#		elif sticker is BattleMove:
#			result.push_back(sticker)
#		else:
#			assert (sticker == null)
#	return result
#
#func create_form() -> MonsterForm:
#	var types = type_override
#	if types.size() == 0:
#		var ntypes = _get_type_native()
#		if ntypes != form.elemental_types:
#			types = ntypes
#	return form.create_type_variant(types)
#
## # # NEW # # #
#func get_exp_to_reach_grade(amount: int) -> int:
#	var exp_points = 0
#	var target_grade = int(min(MAX_TAPE_GRADE, grade + amount))
#	for _grade in range(grade, target_grade):
#		exp_points += BattleFormulas.get_exp_to_next_level(_grade, form.exp_gradient, form.exp_base_level)
#	return exp_points
## # # # # #
#
#func get_exp_to_next_grade() -> int:
#	return BattleFormulas.get_exp_to_next_level(int(min(5, grade)), form.exp_gradient, form.exp_base_level)
#
#func increment_stat(stat_name: String, amount: int):
#	if not stat_increments.has(stat_name):
#		stat_increments[stat_name] = 0
#	stat_increments[stat_name] += amount
#
#func get_upgrade(grade: int) -> Resource:
#	if grade - 1 < form.tape_upgrades.size():
#		var upgrade = form.tape_upgrades[grade - 1]
#		if upgrade is BattleMove:
#			var result = load("res://data/tape_upgrade_scripts/TapeUpgradeMove.gd").new()
#			result.sticker = upgrade
#			return result
#		elif upgrade != null:
#			return upgrade
#	return load("res://data/tape_upgrade_scripts/TapeUpgradeMove.gd").new()
#
#func upgrade_to(new_grade: int, rand: Random, suppress_rand: bool = false):
#
#	while grade < new_grade:
#		grade += 1
#		get_upgrade(grade).apply_npc(self, rand, suppress_rand)
#
#func apply_exp_points(points: int, rand: Random, max_grade: int = - 1):
#	exp_points += points
#
#	var threshold = get_exp_to_next_grade()
#	while exp_points >= threshold and (max_grade < 0 or grade < max_grade):
#		upgrade_to(grade + 1, rand)
#		exp_points -= threshold
#		threshold = get_exp_to_next_grade()
#
#func evolve(evolution: Evolution):
#	if type_native == form.elemental_types:
#		type_native = evolution.evolved_form.elemental_types
#	form = evolution.evolved_form
#	grade = 0
#	stat_increments.clear()
#	if evolution.required_type_override:
#		type_override.erase(evolution.required_type_override)
#
#func try_add_sticker(sticker) -> bool:
#	if sticker == null:
#		return true
#
#	for i in range(get_max_stickers()):
#		if i >= stickers.size():
#			stickers.push_back(sticker)
#			return true
#		elif stickers[i] == null:
#			stickers[i] = sticker
#			return true
#	return false
#
#func force_add_sticker(sticker):
#	if not try_add_sticker(sticker):
#		stickers.push_back(sticker)
#
#func _get_type_native() -> Array:
#	if type_native.size() > 0:
#		return type_native
#	var mapped_types = MonsterForms.get_type_mapping(form)
#	if mapped_types.size() > 0:
#		type_native = mapped_types
#	else:
#		type_native = form.elemental_types
#	return type_native
#
#func get_types() -> Array:
#	if type_override.size() > 0:
#		return type_override
#	return _get_type_native()
#
#func is_bootleg() -> bool:
#	return type_override.size() > 0
#
#func get_evolutions(location: String = "") -> Array:
#	var result = []
#	for evolution in form.evolutions:
#		if evolution.conditions_met(self, location):
#			if evolution.specialization == "":
#				return [evolution]
#			else:
#				result.push_back(evolution)
#	return result
#
#func rand_sticker_rarity(allow_rares: bool, rand: Random = null):
#	if not allow_rares:
#		return BaseItem.Rarity.RARITY_COMMON
#	var distribution = null
#	if is_bootleg():
#		distribution = ItemFactory.BOOTLEG_RARITY_DISTRIBUTION
#	return ItemFactory.rand_rarity(rand, distribution)
#
#func assign_initial_stickers(allow_rares: bool, rand: Random = null, suppress_rand: bool = false) -> void :
#	stickers = []
#	for move in form.initial_moves:
#		var compat_move = BattleMoves.replace_with_compatible(self, move, suppress_rand)
#		var rarity = rand_sticker_rarity(allow_rares, rand)
#		stickers.push_back(ItemFactory.create_sticker(compat_move, rand, rarity))
#
#func get_snapshot():
#	assert (form and form.resource_path != "")
#
#	var type_snap = []
#	for type in type_override:
#		type_snap.push_back(type.resource_path)
#
#	var ntype_snap = []
#	for type in _get_type_native():
#		ntype_snap.push_back(type.resource_path)
#
#	var sticker_snap = []
#	for sticker in stickers:
#		if sticker is StickerItem:
#			sticker_snap.push_back(sticker.get_snapshot())
#		elif sticker is BattleMove:
#			assert (sticker.resource_path != "")
#			sticker_snap.push_back(sticker.resource_path)
#		else:
#			assert (sticker == null)
#			sticker_snap.push_back(null)
#
#	return {
#		"name": name_override, 
#		"hp": [hp.numerator, hp.denominator], 
#		"form": form.resource_path, 
#		"grade": grade, 
#		"exp_points": exp_points, 
#		"seed_value": seed_value, 
#		"type_override": type_snap, 
#		"type_native": ntype_snap, 
#		"stickers": sticker_snap, 
#		"stat_increments": stat_increments, 
#		"favorite": favorite
#	}
#
#func set_snapshot(snap, version: int) -> bool:
#	set_name_override(str(snap.get("name", "")))
#
#	hp.set_to(1, 1)
#	if snap.has("hp"):
#		hp.set_to(snap.hp[0], snap.hp[1])
#
#	if version < 4 and snap.form == "res://data/monster_forms/scourvid.tres":
#		snap.form = "res://data/monster_forms/nevermort.tres"
#	if version < 6 and snap.form == "res://data/monster_forms/wendigore.tres":
#		snap.form = "res://data/monster_forms/folklord.tres"
#	form = load(snap.form) as MonsterForm
#	if not form:
#		return false
#	grade = int(snap.get("grade", 0))
#	exp_points = int(snap.get("exp_points", 0))
#	seed_value = int(snap.get("seed_value", 0))
#
#	type_override = []
#	for type_path in snap.get("type_override", []):
#		var type = load(type_path)
#		if not type:
#			return false
#		type_override.push_back(type)
#
#	type_native = []
#	for type_path in snap.get("type_native", []):
#		var type = load(type_path)
#		if not type:
#			return false
#		type_native.push_back(type)
#
#	var sticker_snaps = snap.stickers if snap.has("stickers") else snap.get("moves", [])
#	stickers = []
#	for sticker_snap in sticker_snaps:
#		if sticker_snap == null:
#			stickers.push_back(null)
#		elif sticker_snap is String:
#			if sticker_snap == "res://data/battle_moves/criticise.tres":
#
#				sticker_snap = "res://data/battle_moves/peekaboo.tres"
#			stickers.push_back(load(sticker_snap))
#		else:
#			stickers.push_back(ItemFactory.recreate_snapshot(sticker_snap, version))
#
#	stat_increments = snap.get("stat_increments", {})
#	favorite = snap.get("favorite", false) == true
#	return true
#
