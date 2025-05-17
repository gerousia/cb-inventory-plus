extends Node

var ref: Character

func _init(value: Character) -> void:
    ref = value

func get_exp_to_reach_level(amount: int) -> int:
	var exp_points = 0
	var target_level = int(min(Character.MAX_MAX_LEVEL, ref.level + amount))
	for level in range(ref.level, target_level):
		exp_points += BattleFormulas.get_exp_to_next_level(level, ref.exp_gradient, ref.exp_base_level)
	return exp_points