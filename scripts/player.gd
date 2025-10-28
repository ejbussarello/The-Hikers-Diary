extends CharacterBody2D

@export var speed: float = 200.0
@export var runner: float = 100.0
@export var jab_cooldown_time: float = 0.5

@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D

var is_attacking: bool = false
var jab_cooldown_timer: float = 0.0
const JAB_ACTION = "jab"

var last_valid_direction: Vector2 = Vector2.DOWN

func _physics_process(delta: float) -> void:
	var input_direction: Vector2 = Vector2.ZERO
	
	var up: float = Input.get_action_strength("move_up")
	var down: float = Input.get_action_strength("move_down")
	input_direction.y = down - up
	
	var left: float = Input.get_action_strength("move_left")
	var right: float = Input.get_action_strength("move_right")
	input_direction.x = right - left
	input_direction = input_direction.normalized()
	
	if input_direction != Vector2.ZERO:
		last_valid_direction = input_direction
	
	if jab_cooldown_timer > 0:
		jab_cooldown_timer -= delta 
	
	if Input.is_action_just_pressed(JAB_ACTION) and not is_attacking and jab_cooldown_timer <= 0:
		_start_jab(last_valid_direction)

	if is_attacking:
		velocity = Vector2.ZERO
	elif Input.is_action_pressed("run"):
		velocity = input_direction * (speed + runner)
	else:
		velocity = input_direction * speed
	
	_update_animation(input_direction)
	move_and_slide()

func _start_jab(direction: Vector2) -> void:
	if is_attacking or jab_cooldown_timer > 0:
		return
	
	is_attacking = true
	jab_cooldown_timer = jab_cooldown_time

	var jab_animation_name = "jab_" + _get_direction_name(direction)
	
	animation_player.play(jab_animation_name)
	
	if not animation_player.is_connected("animation_finished", _on_jab_finished):
		animation_player.connect("animation_finished", _on_jab_finished, CONNECT_ONE_SHOT)

func _on_jab_finished():
	is_attacking = false

func _get_direction_name(direction: Vector2) -> String:
	var angle: float = direction.angle()
	var angle_deg: float = rad_to_deg(angle)
	
	if angle_deg < 0:
		angle_deg += 360.0

	if angle_deg >= 337.5 or angle_deg < 22.5: return "east"
	elif angle_deg >= 22.5 and angle_deg < 67.5: return "south_east"
	elif angle_deg >= 67.5 and angle_deg < 112.5: return "south"
	elif angle_deg >= 112.5 and angle_deg < 157.5: return "south_west"
	elif angle_deg >= 157.5 and angle_deg < 202.5: return "west"
	elif angle_deg >= 202.5 and angle_deg < 247.5: return "north_west"
	elif angle_deg >= 247.5 and angle_deg < 292.5: return "north"
	elif angle_deg >= 292.5 and angle_deg < 337.5: return "north_east"
	return "south"

func _update_animation(direction: Vector2) -> void:
	if is_attacking:
		return

	var animation_name: String
	
	if direction == Vector2.ZERO:
		animation_name = "idle_" + _get_direction_name(last_valid_direction)
	elif Input.is_action_pressed("run"):
		animation_name = "run_" + _get_direction_name(direction)
	else:
		animation_name = "walk_" + _get_direction_name(direction)
			
	if animation_player.animation != animation_name:
		animation_player.play(animation_name)
