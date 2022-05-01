extends KinematicBody2D


export var thrust_power = 50
export (PackedScene) var bullet
export (PackedScene) var explosion
signal give_points(point_value)

var points = 75
var thrust_vector = Vector2(thrust_power, 0)
var thrust_angle = 0
var velocity = Vector2.ZERO
var body_avoiding = null
var body_seeking = null
var obstacles_in_sensors = []

func _physics_process(delta):
	var closest_obstacle
	var angle_to_body
	var engine_power = 1
	if len(obstacles_in_sensors) > 0:
		for obstacle in obstacles_in_sensors:
			if closest_obstacle:
				var closest_obstacle_distance = get_global_position().distance_to(closest_obstacle.get_global_position())
				var obstacle_distance = get_global_position().distance_to(obstacle.get_global_position())
				if obstacle_distance < closest_obstacle_distance:
					closest_obstacle = obstacle
			else:
				closest_obstacle = obstacle 
	if closest_obstacle:
		angle_to_body = get_angle_to(closest_obstacle.get_global_position())
		thrust_angle = angle_to_body + PI
	elif is_instance_valid(body_seeking):
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
		obstacles_in_sensors.push_back(body)
		var asteroid_distance = get_global_position().distance_to(body.get_global_position())
		if body_avoiding and asteroid_distance < get_global_position().distance_to(body_avoiding.get_global_position()):
			body_avoiding = body
		

func _on_SensorArea_body_exited(body):
	if body.is_in_group("asteroids"):
		obstacles_in_sensors.erase(body)
	if body == body_avoiding:
		body_avoiding = null


func _on_Cooldown_timeout():
	if is_instance_valid(body_seeking):
		var shot = bullet.instance()
		shot.position = position
		shot.target = body_seeking
		get_parent().add_child(shot)	
