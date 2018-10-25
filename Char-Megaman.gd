extends KinematicBody2D

const GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 7.0
const MIN_ONAIR_TIME = 0.1
const WALK_SPEED = 90 # pixels/sec
const JUMP_SPEED = 305
const SIDING_CHANGE_SPEED = 10
const BULLET_VELOCITY = 1000
const SHOOT_TIME_SHOW_WEAPON = 0.2

var gravity_vector = Vector2(0, 1)
var linear_vel = Vector2()
var onair_time = 0 #
var on_floor = false
var on_ladder = false
var is_jumping = false
var shoot_time=99999 #time since last shot

var anim=""

#cache the sprite here for fast access (we will set scale to flip it often)
onready var sprite = $Sprite

func _physics_process(delta):
	#increment counters

	onair_time += delta
	shoot_time += delta

	### MOVEMENT ###
	var ray = $RayL
	if not ray.is_colliding():
		ray = $RayR
	if ray.is_colliding():
		if ray.get_collider().get_name() == "Climbable":
			on_ladder = true
			if ray.get_collision_normal() == Vector2(0, -1):
				global_position.y = ray.get_collision_point().y - ray.cast_to.y
		else:
			on_ladder = false
	else:
		on_ladder = false
	
	# Apply Gravity
	linear_vel += delta * GRAVITY_VEC
	
	# Move and Slide
	if on_ladder and (not is_jumping):
		linear_vel.y = 0
		linear_vel = move_and_slide(linear_vel, Vector2(0, 0), SLOPE_SLIDE_STOP)
	else:
		linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)

	# Detect Floor
	if is_on_floor() or on_ladder:
		onair_time = 0

	on_floor = onair_time < MIN_ONAIR_TIME

	### CONTROL ###

	# Horizontal Movement
	var target_speed = 0
	if Input.is_action_pressed("move_left"):
		target_speed += -1
	if Input.is_action_pressed("move_right"):
		target_speed +=  1

	target_speed *= WALK_SPEED
	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)

	# Jumping
	if (on_floor or on_ladder) and Input.is_action_just_pressed("jump"):
		linear_vel.y = -JUMP_SPEED
		is_jumping = true

	if onair_time > 0 and linear_vel.y < 0 and Input.is_action_just_released("jump"):
		linear_vel.y = 0
		
	### ANIMATION ###

	var new_anim = "idle"

	if on_floor:
		if linear_vel.x < -SIDING_CHANGE_SPEED:
			sprite.scale.x = -1
			new_anim = "run"

		if linear_vel.x > SIDING_CHANGE_SPEED:
			sprite.scale.x = 1
			new_anim = "run"
	else:
		# We want the character to immediately change facing side when the player
		# tries to change direction, during air control.
		# This allows for example the player to shoot quickly left then right.
		if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			sprite.scale.x = -1
		if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			sprite.scale.x = 1

		if linear_vel.y < 0:
			new_anim = "jump"
		else:
			new_anim = "jump"

	if new_anim != anim:
		anim = new_anim
		$Animator.play(anim)
