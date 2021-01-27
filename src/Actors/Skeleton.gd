extends KinematicBody2D

export var speed: = Vector2(300.0, 1000)
export var gravity: = 3000
export var total_hit_points: = 5

const ATTACK_LENGTH: = 190

onready var animation_player: = $AnimationPlayer
onready var attack: = $Attack
onready var ray: = $RayCast2D
onready var idle: = $Idle
onready var die: = $Die
onready var collision_shape: = $CollisionShape2D
onready var proj_collision_shape: = $ProjectileDetector/CollisionShape2D
onready var hit: = $Hit
onready var react: = $React
onready var walk: = $Walk
onready var health_bar: = $HealthBar


var hit_points: = 0
var can_be_staggered: = true
var current_animation: = "Idle"
var pause_physics: = false
onready var player: = get_tree().get_root().get_node("Node2D/Player")
var _velocity: = Vector2.ZERO
# direction enemy is facing. true = right, false = left
var last_direction: = true

func _on_AnimationPlayer_attack_finished(anim_name: String) -> void:
	if(anim_name == "Attack"):
		pause_physics = false
	elif(anim_name == "Die"):
		self.queue_free()
	elif(anim_name == "Hit"):
		pause_physics = false

func _on_ProjectileDetector_area_entered(area: Area2D) -> void:
	damage()


func _ready() -> void:
	set_physics_process(false)
	hit_points = total_hit_points

func _physics_process(delta: float) -> void:
	if pause_physics:
		return
	if abs(find_distance_to_player()) < 250:
		attack()
	elif abs(find_distance_to_player()) < 750.0:
		var direction: = process_direction()
		_velocity.x = direction.x * speed.x
		walk()
	else:
		idle()
		_velocity = Vector2.ZERO
	_velocity.y += gravity * delta
	_velocity = move_and_slide(_velocity, Vector2.UP)

func process_direction() -> Vector2:
	return Vector2(1.0 if last_direction else -1.0, 1.0)

func find_distance_to_player() -> float:
	return 	self.position.x - player.position.x

func attack() -> void:
	find_last_direction()
	if current_animation != "Attack":
		get_node(current_animation).set_visible(false)
	attack.flip_h = not last_direction
	attack.set_visible(true)
	animation_player.play("Attack")
	current_animation = "Attack"
	pause_physics = true
	ray.set_cast_to(Vector2(ATTACK_LENGTH  if last_direction else ATTACK_LENGTH * -1, 0))

func idle() -> void:
	find_last_direction()
	if current_animation != "Idle":
		get_node(current_animation).set_visible(false)
	idle.flip_h = not last_direction
	idle.set_visible(true)
	animation_player.play("Idle")
	current_animation = "Idle"

func die() -> void:
	if current_animation != "Die":
		get_node(current_animation).set_visible(false)
	die.flip_h = not last_direction
	die.set_visible(true)
	animation_player.play("Die")
	current_animation = "Die"
	collision_shape.set_deferred("disabled", true)
	proj_collision_shape.set_deferred("disabled", true)
	pause_physics = true

func hit() -> void:
	if current_animation != "Hit":
		get_node(current_animation).set_visible(false)
	hit.flip_h = not last_direction
	hit.set_visible(true)
	animation_player.play("Hit")
	current_animation = "Hit"
	pause_physics = true

func react() -> void:
	if current_animation != "React":
		get_node(current_animation).set_visible(false)
	react.flip_h = not last_direction
	react.set_visible(true)
	animation_player.play("React")
	current_animation = "React"

func walk() -> void:
	find_last_direction()
	if current_animation != "Walk":
		get_node(current_animation).set_visible(false)
	walk.flip_h = not last_direction
	walk.set_visible(true)
	animation_player.play("Walk")
	current_animation = "Walk"

func find_last_direction() -> void:
	if last_direction != (find_distance_to_player() < 0):
		if last_direction == true:
			health_bar.rect_position.x += 100
			collision_shape.move_local_x(100)
		else:
			health_bar.rect_position.x -= 100
			collision_shape.move_local_x(-100)
		last_direction = find_distance_to_player() < 0

func check_attack() -> void:
	if ray.is_colliding():
		player.dmg_player()

func set_animation_position(location: Vector2, flip_displacement: float) -> void:
	collision_shape.set_position(location) if last_direction else collision_shape.set_position(Vector2(location.x + flip_displacement, location.y))
	proj_collision_shape.set_position(location) if last_direction else proj_collision_shape.set_position(Vector2(location.x + flip_displacement, location.y))

func shift_animation_x(value: float) -> void:
	collision_shape.move_local_x(value) if last_direction else collision_shape.move_local_x(-value)
	proj_collision_shape.move_local_x(value) if last_direction else proj_collision_shape.move_local_x(-value)

func set_ray_position(location: Vector2, flip_displacement: float) -> void:
	ray.set_position(location) if last_direction else ray.set_position(Vector2(location.x + flip_displacement, location.y))
	ray.set_rotation_degrees(0)

func damage() -> void:
	hit_points -= 1
	health_bar.value = round(100.0/total_hit_points) * hit_points
	if hit_points == 0:
		die()
	elif float(hit_points)/total_hit_points <= 0.5 and can_be_staggered:
		hit()
		can_be_staggered = false



