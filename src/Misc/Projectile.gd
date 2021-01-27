extends KinematicBody2D

const SPEED: = 1000.0
const PROJ_RANGE: = 500.0
var velocity: = Vector2()
var needs_initialization: = true
var player_direction: = true
var init_position: = 0.0

onready var collision_shape: = $CollisionShape2D
onready var area_collision_shape: = $Area2D/CollisionShape2D
onready var visibility_notifier: = $VisibilityNotifier2D
onready var animated_sprite: = $AnimatedSprite

func _on_Area2D_body_entered(body: Node) -> void:
	kill()


func _physics_process(delta: float) -> void:
	if needs_initialization:
		init_position = self.position.x
		player_direction = get_player_direction()
		needs_initialization = false
		if not player_direction:
			collision_shape.position.x -= 20
			area_collision_shape.position.x -= 20
	if abs(self.position.x - init_position) > PROJ_RANGE:
		kill()
	if not visibility_notifier.is_on_screen():
		kill()
	animated_sprite.flip_h = not player_direction
	velocity.x = SPEED if player_direction else SPEED * -1
	move_and_slide(velocity)
	
func get_player_direction() -> bool:
	return get_tree().get_root().get_node("Node2D/Player").player_facing

func kill() -> void:
	queue_free()

