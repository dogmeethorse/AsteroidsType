extends KinematicBody2D

var velocity = Vector2(50,0)
var target

# Called when the node enters the scene tree for the first time.
func _ready():
	rotation = get_angle_to(target.get_global_position())
	velocity = velocity.rotated(rotation)
	$Sound.play()

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
			if collision.collider.is_in_group("player"):
				collision.collider.on_hit_something()
	
			
func _on_Timer_timeout():
	queue_free()
