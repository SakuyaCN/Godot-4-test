extends Camera2D

func _hit(_scale,_offset):
	var tween = create_tween()
	tween.tween_property(self,"offset",Vector2.ZERO,0.12).from(_offset)
	tween.parallel().tween_property(self,"zoom",Vector2(1.00,1.00),0.12).from(_scale)

func frameFreeze(time_scale, duration):
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale).timeout
	Engine.time_scale = 1
