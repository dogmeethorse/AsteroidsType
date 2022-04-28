extends CPUParticles2D

onready var explosion_timer = $ExplosionTimer


func explode():
	emitting = true
	explosion_timer.start()


func _on_ExplosionTimer_timeout():
	emitting = false
	queue_free()
