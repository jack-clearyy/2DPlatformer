extends KinematicBody2D

export var speed: = Vector2(300.0, 1000)
export var gravity: = 3000
export var hit_points: = 1

const PROJECTILE_LIMIT: = 0.5
const DASH_STRENGTH: = 25

onready var animated_sprite: = $AnimatedSprite

var _velocity: = Vector2.ZERO

# true = right, false = left
var player_facing: = true

# true means player has not used mobility while in air
var double_jump: = true
var dash: = true

var projectile_limit_tracker: = 0.0

var invulnerable: = false

func _on_EnemyDetector_body_entered(body: Node) -> void:
	if (body.get_parent().name == "Spikes"):
		dmg_player()

func _physics_process(delta: float) -> void:
	projectile_limit_tracker += delta
	get_projectile_input()
	var is_jump_interrupted: = Input.is_action_just_released("jump") and _velocity.y < 0.0
	player_facing = get_player_facing(player_facing)
	var direction: = get_direction()
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted, player_facing)
	_velocity = move_and_slide(_velocity, Vector2.UP)

func get_direction() -> Vector2:
	if is_on_floor():
		double_jump = true
		dash = true
	var y_param: = 0.0 # -1.0 if Input.is_action_just_pressed("jump") and is_on_floor() else 1.0
	if Input.is_action_just_pressed("jump") and is_on_floor():
		y_param = -1.0
	elif Input.is_action_just_pressed("jump") and double_jump:
		double_jump = false
		y_param = -1.0
	else:
		y_param = 1.0
	return Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), y_param)

func get_player_facing(player_facing: bool) -> bool:
	var x_dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if x_dir == 0.0:
		return player_facing
	else:
		player_facing = x_dir > 0
		return x_dir > 0

func calculate_move_velocity(linear_velocity: Vector2, direction: Vector2, speed: Vector2, is_jump_interrupted: bool, player_facing: bool) -> Vector2:
	var out: = linear_velocity
	out.x = speed.x * direction.x
	out.y += gravity * get_physics_process_delta_time()
	if direction.y == -1.0:
		out.y = speed.y * direction.y
	if is_jump_interrupted:
		out.y = 0.0
	if Input.is_action_just_pressed("dash") and dash:
		out.x = speed.x * direction.x * DASH_STRENGTH
		dash = false
	# play in_air animation
	if not is_on_floor():
		if invulnerable:
			animated_sprite.animation = "invuln_in_air"
		else:
			animated_sprite.animation = "in_air"
		animated_sprite.flip_h = not player_facing
	# play move_right animation
	elif out.x != 0.0:
		if invulnerable:
			animated_sprite.animation = "invuln_move_right"
		else:
			animated_sprite.animation = "move_right"
		animated_sprite.flip_h = not player_facing
	# play idle animation
	else:
		if invulnerable:
			animated_sprite.animation = "invuln_idle"
		else:
			animated_sprite.animation = "idle"
	return out

func die() -> void:
	PlayerData.deaths += 1
	queue_free()

func get_projectile_input() -> void:
	if Input.is_action_just_pressed("shoot_projectile") and projectile_limit_tracker >= PROJECTILE_LIMIT:
		shoot_projectile()
		projectile_limit_tracker = 0.0

func shoot_projectile() -> void:
	var projectile = load("res://src/Misc/Projectile.tscn")
	var projectile_inst = projectile.instance()
	var projectile_position: = Vector2()
	if is_on_floor():
		projectile_position = Vector2(self.position.x + 90 if player_facing else self.position.x -90, self.position.y - 38)
	else:
		projectile_position = Vector2(self.position.x + 130 if player_facing else self.position.x -130, self.position.y - 20)
	projectile_inst.position = projectile_position
	get_tree().get_root().get_node("Node2D").add_child(projectile_inst)

func dmg_player() -> void:
	if not invulnerable:
		hit_points -= 1
		if hit_points == 0:
			die()
		make_invulnerable()

func make_invulnerable() -> void:
	invulnerable = true
	yield(get_tree().create_timer(3.0), "timeout")
	invulnerable = false

