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

	# LevelGenerator.generate_daily: UTC YYYYMMDD seed
	var d1 := LevelGenerator.generate_daily("20260904")
	var d2 := LevelGenerator.generate_daily("20260904")
	failed += _expect("daily same day deterministic", d1.tube_color_arrays() == d2.tube_color_arrays())
	failed += _expect("daily not complete", not d1.is_complete())
	failed += _expect("daily seed parse", LevelGenerator.date_key_to_seed("20260904") == 20260904)
	var d_other := LevelGenerator.generate_daily("20260905")
	failed += _expect(
		"daily different days differ",
		d1.tube_color_arrays() != d_other.tube_color_arrays()
	)
	failed += _expect("utc_date_key format", SaveService.utc_date_key(0).length() == 8)
	failed += _expect(
		"utc_date_key epoch",
		SaveService.utc_date_key(0) == "19700101"
	)

	# LevelSolver: next pour exists for early campaign levels
	var tip1: Variant = LevelSolver.next_pour(LevelGenerator.generate(1))
	failed += _expect("solver tip level 1", tip1 is Vector2i)
	if tip1 is Vector2i:
		var lv_tip := LevelGenerator.generate(1)
		failed += _expect(
			"solver tip legal",
			PourRules.can_pour(lv_tip.tubes[tip1.x], lv_tip.tubes[tip1.y])
		)
	failed += _expect("solver null when solved", LevelSolver.next_pour(
		Level.new(0, [Tube.new(4, [0, 0, 0, 0]), Tube.new(4, [])])
	) == null)
	var tip_daily: Variant = LevelSolver.next_pour(LevelGenerator.generate_daily("20260904"))
	failed += _expect("solver tip daily", tip_daily is Vector2i)

	# SaveService export / import round-trip (guest backup)
	SaveService.save_progress(12, 11)
	SaveService.save_settings(true, true)
	SaveService.register_daily_clear("20260904")
	var snap: Dictionary = SaveService.build_export_dict()
	failed += _expect("export format", str(snap.get("format", "")) == SaveService.EXPORT_FORMAT)
	failed += _expect("export version", int(snap.get("version", 0)) == SaveService.EXPORT_VERSION)
	SaveService.save_progress(1, 0)
	SaveService.save_settings(false, false)
	failed += _expect("import ok", SaveService.apply_import_dict(snap))
	var p2: Dictionary = SaveService.load_progress()
	failed += _expect("import progress level", int(p2.get("current_level", 0)) == 12)
	failed += _expect("import progress max", int(p2.get("max_completed", 0)) == 11)
	var s2: Dictionary = SaveService.load_settings()
	failed += _expect("import low effects", bool(s2.get("low_effects", false)) == true)
	failed += _expect("reject bad import", not SaveService.apply_import_dict({"format": "nope"}))
	var err_w: Error = SaveService.write_export_file(SaveService.EXPORT_PATH)
	failed += _expect("write export file", err_w == OK)
	SaveService.save_progress(3, 2)
	failed += _expect("read import file", SaveService.read_import_file(SaveService.EXPORT_PATH))
	var p3: Dictionary = SaveService.load_progress()
	failed += _expect("file import level", int(p3.get("current_level", 0)) == 12)

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
