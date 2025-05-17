extends Node

var ref: MonsterTape

func _init(value: MonsterTape) -> void:
    ref = value

func get_exp_to_reach_grade(amount: int) -> int:
	var exp_points = 0
	var target_grade = int(min(ref.MAX_TAPE_GRADE, ref.grade + amount))
	for grade in range(ref.grade, target_grade):
		exp_points += BattleFormulas.get_exp_to_next_level(grade, ref.form.exp_gradient, ref.form.exp_base_level)
	return exp_points