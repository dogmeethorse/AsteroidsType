extends KinematicBody2D


export var thrust_power = 50
export (PackedScene) var explosion
signal give_points(point_value)

var points = 75
var thrust_vector = Vector2(thrust_power, 0)
var thrust_angle = 0
var velocity = Vector2.ZERO
var body_avoiding = null
var body_seeking = null

func _physics_process(delta):
	var angle_to_body
	var engine_power = 1
	if body_avoiding:
		angle_to_body = get_angle_to(body_avoiding.get_global_position())
		thrust_angle = angle_to_body + PI
	elif body_seeking:
		angle_to_body = get_angle_to(body_seeking.get_global_position())
		thrust_angle = angle_to_body
	else:
		engine_power = 0
		
	velocity = velocity + thrust_vector.rotated(thrust_angle)  * delta * engine_power
	velocity = move_and_slide(velocity)
	for slide in get_slide_count():
		var collision = get_slide_collision(slide)
		if collision.collider.is_in_group("player"):
			collision.collider.on_hit_something() 
	
func on_hit_something():
	emit_signal("give_points", points)
	var my_explosion = explosion.instance()
	my_explosion.global_position = global_position
	get_parent().add_child(my_explosion)
	my_explosion.explode()
	queue_free()

func _on_SensorArea_body_entered(body):
	if body.is_in_group("asteroids"):
		var asteroid_distance = get_global_position().distance_to(body.get_global_position())
		if body_avoiding and asteroid_distance < get_global_position().distance_to(body_avoiding.get_global_position()):
			body_avoiding = body
		else:
			body_avoiding = body
	if body.is_in_group("player"):
		body_seeking = body
		

func _on_SensorArea_body_exited(body):
	if body == body_avoiding:
		body_avoiding = null
