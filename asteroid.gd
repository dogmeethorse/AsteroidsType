extends RigidBody2D

enum {BIG, MEDIUM, SMALL}
const split_number = 2
signal give_points(point_value)

onready var collision_shape_big = $CollisionShapeBig
onready var collision_shape_med = $CollisionShapeMed
onready var collision_shape_small = $CollisionShapeSm
var new_asteroid = load("res://asteroid.tscn")
var size = BIG
var points = 25

func set_size(new_size):
	if size == BIG:
		collision_shape_med.queue_free()
		collision_shape_small.queue_free()
	elif size == MEDIUM:
		collision_shape_big.queue_free()
		collision_shape_small.queue_free()
	elif size == SMALL:
		collision_shape_big.queue_free()
		collision_shape_med.queue_free()
		#set_deferred("collision_shapes[size].disabled", true )
		#set_deferred("collision_shapes[new_size].disabled", false )
	size = new_size
	$Sprite.frame = size


func _ready():
	randomize()
	set_size(size)
	linear_velocity = Vector2(randi()%100 - 50, randi()%100 - 50)
	angular_velocity = randf() * PI

func _integrate_forces(state):
	var screen_size = get_viewport_rect().size
	var xform = state.get_transform()
	xform.origin.x = wrapf(xform.origin.x, 0, screen_size.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screen_size.y)
	state.set_transform(xform)
	for body in get_colliding_bodies():
		if body is KinematicBody2D:
			if body.has_method("on_hit_something"):
				body.on_hit_something()
			blow_up(xform)

func blow_up(xform):
	emit_signal("give_points", points)
	if size != SMALL:
		var parent = get_parent()
		parent.remove_child(self)
		for _i in range(split_number):
			var baby_asteroid = new_asteroid.instance()
			baby_asteroid.position = xform.origin
			baby_asteroid.size = size + 1
			parent.call_deferred("add_child", baby_asteroid)
	queue_free()	
