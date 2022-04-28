extends KinematicBody2D

export (PackedScene) var bullet
export (PackedScene) var explosion

onready var root_node = get_tree().root
onready var ship_exhaust = $ShipExhaust
onready var cool_down = $CoolDown

signal player_ship_destroyed
   
const thrust_power = 100
const rotation_amount = PI/30

var velocity = Vector2(0,0)
var can_shoot = true
# Called when the node enters the scene tree for the first time.


func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	#handle input 
	if Input.is_action_pressed("forward"):
		velocity = velocity + Vector2(thrust_power, 0).rotated(rotation) * delta
		ship_exhaust.emitting  = true
	else:
		ship_exhaust.emitting = false
	if Input.is_action_pressed("back"):
		velocity = velocity + Vector2(-thrust_power,0).rotated(rotation) * delta
	if Input.is_action_pressed("right"):
		rotation = rotation + rotation_amount
	if Input.is_action_pressed("left"):
		rotation = rotation - rotation_amount
	
	if Input.is_action_pressed("shoot") and can_shoot:
			can_shoot = false
			cool_down.start()
			var shot_offset = Vector2(20,0)
			var shot_fired = bullet.instance()
			shot_fired.position = position + shot_offset.rotated(rotation)
			shot_fired.rotation = rotation
			get_parent().add_child(shot_fired)
			shot_fired.velocity = shot_fired.velocity + velocity
			
	velocity = move_and_slide(velocity)
	
	
func on_hit_something():
	var my_explosion = explosion.instance()
	my_explosion.global_position = global_position
	get_parent().add_child(my_explosion)
	my_explosion.explode()
	emit_signal("player_ship_destroyed")
	queue_free()
	
	
func _on_cooldown_timeout():
	can_shoot = true
