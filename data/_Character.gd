#tool 
#extends BaseForm
#class_name Character
#
#signal appearance_changed
#signal pronouns_changed(pronouns)
#
#const MAX_MAX_LEVEL: int = 999
#const DEFAULT_MAX_LEVEL: int = 200
#
#const MAX_NAME_WIDTH: int = 220
#
#const STAT_BASE: int = 100
#const CHANCE_STAT_BASE: int = 100
#
#const REL_LEVEL_FUSION: int = 1
#const REL_LEVEL_FUSION_POWER: int = 2
#const REL_LEVEL_MAX: int = 5
#
#const RELATIONSHIP_GRADIENT: int = 30
#
#const SIGNATURE_TAPE_BOOSTED_STATS = {
#	max_hp = true, 
#	melee_attack = true, 
#	melee_defense = true, 
#	ranged_attack = true, 
#	ranged_defense = true, 
#	speed = true
#}
#
#enum CharacterKind{MONSTER, HUMAN, ARCHANGEL, GHOST_TEMPORARY, SUMMON, GHOST_PERSISTENT, GHOST_HUMAN}
#enum APSystem{SPEND, ACCUMULATE}
#enum RelationshipKind{PLATONIC, DATING, ROMANTIC}
#
#export (PackedScene) var battle_sprite: PackedScene
#
#export (CharacterKind) var character_kind: int = CharacterKind.MONSTER setget set_character_kind
#export (bool) var force_unrecordable: bool = false
#export (Dictionary) var human_colors: Dictionary setget set_human_colors
#export (Dictionary) var human_part_names: Dictionary setget set_human_part_names
#export (PackedScene) var world_sprite: PackedScene setget set_world_sprite
#
#var hp: Rational = Rational.new(1, 1)
#
#export (int, 1, 200) var level: int = 1 setget set_level
#export (int, "He", "She", "They") var pronouns: int = 2 setget set_pronouns
#
#export (int, 0, 10) var max_ap: int = 5
#export (int, 0, 20) var base_ap_regen: int = 2
#export (int, 0, 1000) var base_max_hp: int = STAT_BASE
#export (int, 0, 1000) var base_melee_attack: int = STAT_BASE
#export (int, 0, 1000) var base_melee_defense: int = STAT_BASE
#export (int, 0, 1000) var base_ranged_attack: int = STAT_BASE
#export (int, 0, 1000) var base_ranged_defense: int = STAT_BASE
#export (int, 0, 1000) var base_speed: int = STAT_BASE
#export (int, 0, 1000) var base_accuracy: int = CHANCE_STAT_BASE
#export (int, 0, 1000) var base_evasion: int = CHANCE_STAT_BASE
#
#export (Array, Resource) var tapes: Array
#
#export (String) var team_name_override: String = ""
#
#export (int) var exp_gradient: int = 5
#export (int) var exp_base_level: int = 0
#var exp_points: int = 0
#
#
#export (String) var partner_id: String = ""
#export (Resource) var partner_signature_species: Resource
#var relationship_points: int = 0
#var relationship_level: int = 0
#var relationship_kind: int = RelationshipKind.PLATONIC
#
#var recent_event: String = ""
#
#
#
#var background_levels_gained: int
#
#var boost_max_hp: int = 0
#var boost_melee_attack: int = 0
#var boost_melee_defense: int = 0
#var boost_ranged_attack: int = 0
#var boost_ranged_defense: int = 0
#var boost_speed: int = 0
#
#export (Resource) var sfx: Resource
#
#static func is_ghost(character_kind: int) -> bool:
#	return character_kind == CharacterKind.GHOST_TEMPORARY or character_kind == CharacterKind.GHOST_PERSISTENT or character_kind == CharacterKind.GHOST_HUMAN
#
#static func is_human(character_kind: int) -> bool:
#	return character_kind == CharacterKind.HUMAN or character_kind == CharacterKind.GHOST_HUMAN
#
#static func is_archangel(character_kind: int) -> bool:
#	return character_kind == CharacterKind.ARCHANGEL
#
#func _init():
#	human_colors = {}
#	human_part_names = {}
#
#func _update_res_name():
#	if not Engine.editor_hint:
#		return
#	if resource_path != "" and not ("::" in resource_path):
#		resource_name = resource_path.get_file()
#	else:
#		if name != "":
#			resource_name = name
#		elif character_kind == CharacterKind.MONSTER:
#			resource_name = "Monster"
#		elif character_kind == CharacterKind.HUMAN:
#			resource_name = "Human"
#		elif character_kind == CharacterKind.ARCHANGEL:
#			resource_name = "Archangel"
#		elif character_kind == CharacterKind.GHOST_TEMPORARY:
#			resource_name = "Ghost (Temporary)"
#		elif character_kind == CharacterKind.SUMMON:
#			resource_name = "Summon"
#		elif character_kind == CharacterKind.GHOST_PERSISTENT:
#			resource_name = "Ghost (Persistent)"
#		elif character_kind == CharacterKind.GHOST_HUMAN:
#			resource_name = "Ghost (Human)"
#		resource_name += " Lv" + str(level)
#
#func set_name(value: String):
#	.set_name(value)
#	_update_res_name()
#
#func set_level(value: int):
#	level = int(clamp(value, 1, MAX_MAX_LEVEL))
#	_update_res_name()
#
#func set_pronouns(value: int):
#	pronouns = value
#	emit_signal("pronouns_changed", pronouns)
#
#func set_character_kind(value: int):
#	character_kind = value
#	_update_res_name()
#
#func battle_sprite_instance() -> Spatial:
#	if battle_sprite:
#		return battle_sprite.instance() as Spatial
#	if is_human(character_kind):
#		var result = preload("res://nodes/layered_sprite/BattleHumanSprite3D.tscn").instance()
#		result.set_colors(human_colors)
#		result.set_part_names(human_part_names)
#		return result
#	return null
#
#func get_stat(stat_name: String, tape: MonsterTape) -> int:
#	var result: int = get("base_" + stat_name)
#
#	var boost = get("boost_" + stat_name)
#	if boost != null:
#		result += int(boost)
#
#	if tape != null and SIGNATURE_TAPE_BOOSTED_STATS.has(stat_name):
#
#
#		if _signature_species_match(partner_signature_species, tape.form):
#			result = result * 110 / 100
#
#	return result
#
#func _signature_species_match(require: MonsterForm, species: MonsterForm) -> bool:
#	if require == null:
#		return false
#	if species == require:
#		return true
#	for evolution in require.evolutions:
#		if _signature_species_match(evolution.evolved_form, species):
#			return true
#	return false
#
## # # NEW # # #
#func get_exp_to_reach_level(amount: int) -> int:
#	var exp_points = 0
#	var target_level = int(min(MAX_MAX_LEVEL, level + amount))
#	for _level in range(level, target_level):
#		exp_points += BattleFormulas.get_exp_to_next_level(_level, exp_gradient, exp_base_level)
#	return exp_points
## # # # # #
#
#func get_exp_to_next_level() -> int:
#	return BattleFormulas.get_exp_to_next_level(level, exp_gradient, exp_base_level)
#
#func get_exp_to_next_relationship_level() -> int:
#	return BattleFormulas.get_exp_to_next_level(relationship_level, RELATIONSHIP_GRADIENT, 0)
#
#func get_total_exp() -> int:
#	return BattleFormulas.get_exp_to_level(level, exp_gradient, exp_base_level) + exp_points
#
#func is_fusion_unlocked() -> bool:
#	return relationship_level >= REL_LEVEL_FUSION
#
#func is_fusion_power_unlocked() -> bool:
#	return relationship_level >= REL_LEVEL_FUSION_POWER
#
#func get_ap_system() -> int:
#	if character_kind == CharacterKind.ARCHANGEL:
#		return APSystem.ACCUMULATE
#	return APSystem.SPEND
#
#func get_snapshot():
#	var snap = {
#		"hp": [hp.numerator, hp.denominator], 
#		"level": level, 
#		"exp_points": exp_points, 
#		"tapes": [], 
#		"relationship_level": relationship_level, 
#		"relationship_points": relationship_points, 
#		"relationship_kind": relationship_kind, 
#		"recent_event": recent_event, 
#		"background_levels_gained": background_levels_gained, 
#		"boost": {
#			"max_hp": boost_max_hp, 
#			"melee_attack": boost_melee_attack, 
#			"melee_defense": boost_melee_defense, 
#			"ranged_attack": boost_ranged_attack, 
#			"ranged_defense": boost_ranged_defense, 
#			"speed": boost_speed
#		}, 
#		"custom": {
#			"human_colors": human_colors, 
#			"human_part_names": human_part_names, 
#			"name": name, 
#			"pronouns": int(pronouns)
#		}
#	}
#	for tape in tapes:
#		snap.tapes.push_back(tape.get_snapshot())
#	return snap
#
#func set_snapshot(snap, version: int) -> bool:
#	hp.set_to(1, 1)
#	if snap.hp is Array:
#		hp.set_to(int(snap.hp[0]), int(snap.hp[1]))
#
#	level = int(snap.level)
#	exp_points = snap.get("exp_points", 0)
#
#	tapes = []
#	for tape_snap in snap.tapes:
#		var tape = MonsterTape.new()
#		if not tape.set_snapshot(tape_snap, version):
#			return false
#		tapes.push_back(tape)
#
#	relationship_level = int(snap.get("relationship_level", 0))
#	relationship_points = int(snap.get("relationship_points", 0))
#	relationship_kind = int(snap.get("relationship_kind", RelationshipKind.PLATONIC))
#	recent_event = snap.get("recent_event", "")
#	background_levels_gained = int(snap.get("background_levels_gained", 0))
#
#	if snap.has("boost"):
#		var boost = snap.boost
#		boost_max_hp = int(boost.get("max_hp", 0))
#		boost_melee_attack = int(boost.get("melee_attack", 0))
#		boost_melee_defense = int(boost.get("melee_defense", 0))
#		boost_ranged_attack = int(boost.get("ranged_attack", 0))
#		boost_ranged_defense = int(boost.get("ranged_defense", 0))
#		boost_speed = int(boost.get("speed", 0))
#
#	if snap.has("custom"):
#		human_colors = HumanLayersHelper.validate_colors(snap.custom.human_colors.duplicate())
#		human_part_names = HumanLayersHelper.validate_part_names(snap.custom.human_part_names.duplicate())
#		if human_part_names.has("body"):
#			human_part_names.arms = human_part_names.body
#		name = snap.custom.name
#		pronouns = int(snap.custom.get("pronouns", Loc.Pronouns.THEY))
#
#		if partner_id == "kayleigh" and human_part_names.get("wings") == "":
#			human_part_names.wings = "sirenade"
#
#		emit_signal("appearance_changed")
#		emit_signal("pronouns_changed", pronouns)
#
#	return true
#
#func _get_property_list():
#	var properties = []
#	HumanLayersHelper.add_world_human_properties(properties)
#	return properties
#
#func _set(property: String, value) -> bool:
#	if HumanLayersHelper.set_human_property(property, value, human_part_names, human_colors):
#		emit_signal("appearance_changed")
#		return true
#	return false
#
#func _get(property: String):
#	return HumanLayersHelper.get_human_property(property, human_part_names, human_colors)
#
#func set_human_colors(value: Dictionary):
#	human_colors = value
#	emit_signal("appearance_changed")
#
#func set_human_part_names(value: Dictionary):
#	human_part_names = value
#	emit_signal("appearance_changed")
#
#func set_world_sprite(value: PackedScene):
#	world_sprite = value
#	emit_signal("appearance_changed")
