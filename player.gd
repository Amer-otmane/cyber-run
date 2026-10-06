extends CharacterBody3D

const JUMP_VELOCITY  = 8.0
const GRAVITY        = 20.0
const LANE_DISTANCE  = 2.0

var current_lane : int   = 0
var target_x     : float = 0.0

var is_sliding  = false
var slide_timer = 0.0
const SLIDE_DURATION = 0.8

@onready var col = $CollisionShape3D

func _ready():
	$MeshInstance3D.visible = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if is_sliding:
			_stop_slide()

	if Input.is_action_just_pressed("ui_down") and is_on_floor() and not is_sliding:
		_start_slide()

	if is_sliding:
		slide_timer += delta
		if slide_timer >= SLIDE_DURATION:
			_stop_slide()

	if Input.is_action_just_pressed("ui_left") and current_lane > -1:
		current_lane -= 1

	if Input.is_action_just_pressed("ui_right") and current_lane < 1:
		current_lane += 1

	target_x   = float(current_lane) * LANE_DISTANCE
	position.x = lerp(position.x, target_x, delta * 10.0)
	velocity.z = 0.0
	move_and_slide()

func _start_slide():
	is_sliding     = true
	slide_timer    = 0.0
	col.scale.y    = 0.4
	col.position.y = -0.3

func _stop_slide():
	is_sliding     = false
	slide_timer    = 0.0
	col.scale.y    = 1.0
	col.position.y = 0.0
