class_name PuzzleTween

static func play_popup_tween(obj:Node2D, dur_bounds := Vector2(0.2, 0.6)) -> Tween:
	var tw := obj.get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	var dur := randf_range(dur_bounds.x, dur_bounds.y)
	obj.set_scale(Vector2.ZERO)
	tw.tween_property(obj, "scale", Vector2.ONE, dur)
	return tw

static func play_popdown_tween(obj:Node2D, dur_bounds := Vector2(0.2, 0.6)) -> Tween:
	var tw := obj.get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	var dur := randf_range(dur_bounds.x, dur_bounds.y)
	tw.tween_property(obj, "scale", Vector2.ZERO, dur)
	return tw

static func play_resize_tween(obj:Node2D, scale:Vector2, dur_bounds := Vector2(0.2, 0.5)) -> Tween:
	var tw := obj.get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	var dur := randf_range(dur_bounds.x, dur_bounds.y)
	tw.tween_property(obj, "scale", scale, dur)
	return tw

static func play_wiggle_tween(obj:Node2D, amp_bounds := Vector2(0.02, 0.04)) -> Tween:
	var tw := obj.get_tree().create_tween()
	var dur := randf_range(0.1, 0.25)
	var amplitude = randf_range(amp_bounds.x, amp_bounds.y) * PI
	tw.tween_property(obj, "rotation", -amplitude, 0.25*dur)
	tw.tween_property(obj, "rotation", amplitude, 0.5*dur)
	tw.tween_property(obj, "rotation", 0, 0.25*dur)
	return tw

# @TODO
# PuzzleFeedback.TYPE would be some default GOOD/NEUTRAL/BAD
# feedback_scene would be something that automatically animates itself popping in, fading away, deleting itself
#static func give_feedback(cont:Node2D, txt:String, type:PuzzleFeedback.Type) -> Node2D:
	#var fb := feedback_scene.instantiate()
	#fb.set_data(txt, type)
	#cont.add_child(fb)

static func force_tween_completion(tw:Tween, dur := 10.0) -> void:
	if not tw.is_running(): return
	
	tw.pause()
	tw.custom_step(dur)

# @TODO: this likely won't work; can I make an easy system for remembering properties and resetting as if the tween never happened/started?
# Why the fuck is this not a standard feature of Tweens?
static func force_tween_reset(tw:Tween, dur := 10.0) -> void:
	tw.pause()
	tw.custom_step(-dur)
