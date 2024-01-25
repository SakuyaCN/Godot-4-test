extends Node2D

func _ready():
	var tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(self,"scale",Vector2(1.5,1.5),0.2).from(Vector2(0.5,0.5))
	tween.tween_property(self,"scale",Vector2(1,1),0.1).from(Vector2(1.5,1.5))
	
	tween.tween_property(self,"position:y",self.position.y - 20,0.3).set_delay(0.3)
	tween.parallel().tween_property(self,"modulate:a",0.0,0.3).set_delay(0.3)

	var t2 = create_tween()
	t2.tween_property(self,"modulate",Color.AQUA,0.1)
	t2.tween_property(self,"modulate",Color.GOLD,0.1)
	t2.tween_property(self,"modulate",Color.CRIMSON,0.1)
	
