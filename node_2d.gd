extends Node2D

@onready var combo_panel = $CanvasLayer/Control/Panel
@onready var combo_label = $CanvasLayer/Control/Panel/Label
@onready var timer = $CanvasLayer/Control/Timer

var combo = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setCombo():
	if !timer.is_stopped():
		timer.stop()
	combo_panel.show()
	combo += 1
	var tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(combo_label,"scale",Vector2(1,1),0.3).from(Vector2(2,2))
	tween.parallel().tween_property(combo_label,"modulate",Color.TOMATO,0.3)
	tween.parallel().tween_property(combo_label,"modulate",Color('#fff381'),0.3).set_delay(0.3)
	combo_label.text = 'COMBO %s !!!' %combo
	timer.start()


func _on_timer_timeout() -> void:
	combo_panel.hide()
	combo = 0
