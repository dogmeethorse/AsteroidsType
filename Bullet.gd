extends KinematicBody2D

onready var collision_shape = $CollisionShape2D
onready var red_particles = $RedParticles
onready var particle_timer = $ParticleTimer
onready var sprite = $Sprite

var velocity = Vector2(200,0)

func _ready():
	velocity = velocity.rotated(rotation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var collision = move_and_collide(velocity * delta, true)
	if collision:
		on_hit_something()
		if collision.collider.has_method("on_hit_something"):
			collision.collider.on_hit_something()
		
func _on_Lifespan_timeout():
	queue_free()

func on_hit_something():
	#set_deferred("collision_shape.disabled", true)
	collision_shape.queue_free()
	sprite.visible = false
	red_particles.emitting = true
	particle_timer.start()

func _on_ParticleTimer_timeout():
	red_particles.emitting = false
