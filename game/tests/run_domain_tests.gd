extends SceneTree

func _init() -> void:
	var failed := 0
	failed += _expect("empty cannot pour", not PourRules.can_pour(
		Tube.new(4, []), Tube.new(4, [])
	))
	var a := Tube.new(4, [1, 1])
	var b := Tube.new(4, [])
	failed += _expect("pour into empty", PourRules.can_pour(a, b))
	var moved := PourRules.apply_pour(a, b)
	failed += _expect("moved 2", moved == 2)
	failed += _expect("source empty", a.is_empty())
	failed += _expect("dest has two", b.colors == [1, 1])
	# same-color top only continuous block
	var c := Tube.new(4, [2, 1, 1])
	var d := Tube.new(4, [1])
	failed += _expect("pour matching top", PourRules.can_pour(c, d))
	moved = PourRules.apply_pour(c, d)
	failed += _expect("moved two ones", moved == 2 and d.colors == [1, 1, 1] and c.colors == [2])

	# LevelGenerator: determinism + campaign params
	var g1 := LevelGenerator.generate(7)
	var g2 := LevelGenerator.generate(7)
	failed += _expect("generate(7) deterministic", g1.tube_color_arrays() == g2.tube_color_arrays())

	var lv1 := LevelGenerator.generate(1)
	failed += _expect("generate(1) 3 colors", lv1.color_count() == 3)
	failed += _expect("generate(1) capacity 4", lv1.capacity() == 4)
	failed += _expect("generate(1) not complete", not lv1.is_complete())

	failed += _expect("generate(7) not complete", not g1.is_complete())

	if failed == 0:
		print("DOMAIN_TESTS_OK")
		quit(0)
	else:
		print("DOMAIN_TESTS_FAILED ", failed)
		quit(1)


func _expect(label: String, cond: bool) -> int:
	if cond:
		return 0
	print("FAIL: ", label)
	return 1
