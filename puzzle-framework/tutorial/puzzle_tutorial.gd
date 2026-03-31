class_name PuzzleTutorial

static func play_focus_grab_tween(obj:Node2D) -> Tween:
	var tw_wiggle := obj.get_tree().create_tween()
	var dur := randf_range(0.05, 0.15)
	var amplitude = randf_range(0.05, 0.1) * PI
	tw_wiggle.tween_property(obj, "rotation", -amplitude, dur)
	tw_wiggle.tween_property(obj, "rotation", amplitude, 2*dur)
	tw_wiggle.tween_property(obj, "rotation", -amplitude, 2*dur)
	tw_wiggle.tween_property(obj, "rotation", amplitude, 2*dur)
	tw_wiggle.tween_property(obj, "rotation", -amplitude, 2*dur)
	tw_wiggle.tween_property(obj, "rotation", amplitude, 2*dur)
	tw_wiggle.tween_property(obj, "rotation", -amplitude, 2*dur)
	tw_wiggle.tween_property(obj, "rotation", amplitude, 2*dur)
	tw_wiggle.tween_property(obj, "rotation", 0, dur)
	
	var tw := obj.get_tree().create_tween()
	var dur_flash := 0.25
	tw.tween_property(obj, "modulate", Color(3, 3, 3), dur_flash)
	tw.tween_property(obj, "modulate", Color.WHITE, dur_flash)
	tw.tween_property(obj, "modulate", Color(2,2,2), dur_flash)
	tw.tween_property(obj, "modulate", Color.WHITE, dur_flash)
	tw.tween_property(obj, "modulate", Color(1.35, 1.35, 1.35), dur_flash)
	tw.tween_property(obj, "modulate", Color.WHITE, dur_flash)
	return tw

static func play_pointer_tween(obj:Node2D, pos:Vector2) -> Tween:
	obj.show()
	obj.z_index = 1024
	obj.set_position(pos)
	
	var tw := obj.get_tree().create_tween()
	tw.tween_property(obj, "position", pos + Vector2.RIGHT*8.0, 0.5)
	tw.tween_property(obj, "position", pos, 0.5)
	tw.tween_property(obj, "position", pos + Vector2.RIGHT*8.0, 0.5)
	tw.tween_property(obj, "position", pos, 0.5)
	tw.tween_property(obj, "position", pos + Vector2.RIGHT*8.0, 0.5)
	tw.tween_property(obj, "position", pos, 0.5)
	tw.tween_callback(obj.hide)
	return tw
