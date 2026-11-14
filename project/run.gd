extends SceneTree


func _init() -> void:
	if not ClassDB.class_exists("Sandbox"):
		print("RESULT: FAIL the Sandbox class is not in this Godot build")
		quit(2)
		return
	var sb = ClassDB.instantiate("Sandbox")
	sb.set("program", load("res://omnigen2.elf"))
	var ok := true
	var version = str(sb.vmcall("omnigen2_version"))
	if version == "omnigen2-guest 0.0.1":
		print("RESULT: vmcall omnigen2_version == ", version)
	else:
		print("RESULT: FAIL vmcall omnigen2_version gave ", version)
		ok = false
	var clean = str(sb.vmcall("omnigen2_ask", "mul_mat"))
	if clean == '{"op":"mul_mat","flip":false,"match":true}':
		print("RESULT: vmcall omnigen2_ask(mul_mat) matches the fixture")
	else:
		print("RESULT: FAIL vmcall omnigen2_ask(mul_mat) gave ", clean)
		ok = false
	var flipped = str(sb.vmcall("omnigen2_ask", "mul_mat flip"))
	if flipped == '{"op":"mul_mat","flip":true,"match":false}':
		print("RESULT: vmcall omnigen2_ask(mul_mat flip) is refused, the control holds")
	else:
		print("RESULT: FAIL vmcall omnigen2_ask(mul_mat flip) gave ", flipped)
		ok = false
	var unknown = str(sb.vmcall("omnigen2_ask", "conv2d"))
	if unknown == '{"refused":"unknown_op"}':
		print("RESULT: vmcall omnigen2_ask(conv2d) is refused by name")
	else:
		print("RESULT: FAIL vmcall omnigen2_ask(conv2d) gave ", unknown)
		ok = false
	sb.free()
	quit(0 if ok else 1)
