extends CharacterBody2D

const _hit_label = preload("res://HitLabel.tscn")

@export var is_action = false
@export var is_effect = true

@onready var anim = $AnimatedSprite2D
@onready var combo_timer = $ComboTimer
@onready var effect_anim = $effect
@onready var camera = $Camera2D
@onready var stab = $AnimatedSprite2D2

@onready var hit_box_1 = $HitBox1/CollisionShape2D
@onready var hit_box_2 = $HitBox2/CollisionShape2D
@onready var hit_box_3 = $HitBox3/CollisionShape2D

@onready var audio = $AudioStreamPlayer2D

const SPEED = 350.0
const JUMP_VELOCITY = -400.0

var combo_count = 1
var is_in_combo = false
var is_air_atk = false
var is_on_hit = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	set_process(is_action)
	if !is_action:
		anim.flip_h = true

func _process(delta: float) -> void:
	if Input.is_action_pressed("atk"):
		is_in_combo = true
		if !combo_timer.is_stopped():
			combo_timer.stop()
		
		if is_on_floor():
			anim.play("atk_%s" %combo_count)
		else:
			is_air_atk = true
			anim.play("air_atk")
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func _physics_process(delta: float) -> void:
	
	if is_air_atk && is_on_floor():
		is_air_atk = false
		is_in_combo = false
	
	if is_in_combo && !is_air_atk:
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta

	if !is_air_atk && !is_on_hit:
		changeAnim()
	
	if is_on_hit && !is_effect:
		position.x += 50 * delta
		position.y -= 150 * delta
	
	move_and_slide()
	
	if velocity.x > 0:
		anim.flip_h = false
	elif velocity.x < 0:
		anim.flip_h = true

func changeAnim():
	if velocity == Vector2.ZERO:
		anim.play("idle")
	else:
		anim.play("run")
	
	if !is_on_floor():
		anim.play("jump")

func on_hit():
	is_on_hit = true
	anim.play("hit")
	showLabel()
	hitModulate()
#	if !audio.playing:

func _on_combo_timer_timeout() -> void:
	combo_count = 1

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation.countn('hit'):
		velocity.x = 0
		is_on_hit = false
	
	if anim.animation.countn('atk'):
		if combo_count < 3:
			combo_count += 1
		else:
			combo_count = 1
		combo_timer.start()
	is_in_combo = false

func _on_hit_box_body_entered(body: Node2D) -> void:
	body.on_hit()
	#if is_effect:
	body.showEffect("hit%s" %(combo_count))
	#camera._hit(Vector2(0.995,0.995),Vector2(6,-4))
	if combo_count == 3:
		camera._hit(Vector2(0.950,0.950),Vector2(7,-9))
		camera.frameFreeze(0.1,0.09)
	else:
		camera._hit(Vector2(0.990,0.990),Vector2(3,-4))
		camera.frameFreeze(0.1,0.06)
	if combo_count != 3:
		audio.stream = load("res://audio/PUNCH_DESIGNED_HEAVY_86.wav")
	else:
		audio.stream = load("res://audio/PUNCH_SQUELCH_HEAVY_01.wav")
	audio.play()

func showLabel():
	var ins = _hit_label.instantiate()
	ins.global_position = Vector2(global_position.x + randi_range(30,60),global_position.y - randi_range(100,150))
	get_parent().add_child(ins)
	get_parent().setCombo()

func hitModulate():
	var tweem = create_tween()
	tweem.tween_property(anim,"modulate",Color.WHITE,0.2).from(Color.BROWN)

func _on_animated_sprite_2d_frame_changed() -> void:
	if anim:
		if anim.animation == 'atk_1' && anim.frame == 1:
			setCollisionDisabled(hit_box_1)
			if !stab.is_playing() && !is_effect:
				stab.play("default")
		if anim.animation == 'atk_2' && anim.frame == 1:
			setCollisionDisabled(hit_box_2)
			if !stab.is_playing() && !is_effect:
				stab.play("default")
		if anim.animation == 'atk_3' && anim.frame == 4:
			setCollisionDisabled(hit_box_3)
			if !stab.is_playing() && !is_effect:
				stab.play("default")

func setCollisionDisabled(hit_box):
	hit_box.call_deferred('set_disabled',false)
	await get_tree().create_timer(0.1).timeout
	hit_box.call_deferred('set_disabled',true)

func showEffect(_name):
	effect_anim.play(_name)
	effect_anim.show()

func _on_effect_animation_finished() -> void:
	effect_anim.hide()
