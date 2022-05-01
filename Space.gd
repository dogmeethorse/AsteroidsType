extends Node2D

#export (PackedScene) var player_ship
export (PackedScene) var asteroids
export (PackedScene) var ships

var score = 0
var player_alive = true
var difficulty = 3
var current_spawn_location = 0
onready var spawns = [$SpawnPoint1, $SpawnPoint2, $SpawnPoint3, $SpawnPoint4, $SpawnPoint5, $SpawnPoint6] 
onready var scoreboard = $Score

# Called when the node enters the scene tree for the first time.
func _ready():
	for _i in range(difficulty):
		spawn_asteroid()

func select_safe_spawn(first_choice):
	var test_spot = first_choice
	if spawns[test_spot].get_overlapping_bodies().empty():
		return test_spot
	else:
		for spawn in len(spawns):
			if spawns[spawn].get_overlapping_bodies().empty():
				return spawn
	return null
		
	

func spawn_asteroid():
	var safe_spawn = select_safe_spawn(current_spawn_location)
	if safe_spawn != null:
		var new_asteroid = asteroids.instance()
		new_asteroid.position = spawns[current_spawn_location].position
		current_spawn_location = current_spawn_location + 1
		current_spawn_location = wrapf(current_spawn_location, 0, len(spawns)-1)
		add_child(new_asteroid)
		new_asteroid.connect("give_points", self, "_on_give_points")


func spawn_ship():
	var safe_spawn = select_safe_spawn(randi() % len(spawns)) 
	if safe_spawn != null: 
		var new_ship = ships.instance()
		new_ship.position = spawns[safe_spawn].position
		add_child(new_ship)
		$ShipSpawnSound.play()
		if player_alive:
			new_ship.body_seeking = $PlayerShip
		new_ship.connect("give_points", self, "_on_give_points")
	
	
func _physics_process(_delta):
	var screen_size = get_viewport_rect().size
	for child in get_children():
		if child is KinematicBody2D:
			child.position.x = wrapf(child.position.x, 0, screen_size.x)
			child.position.y = wrapf(child.position.y, 0, screen_size.y)


func set_score():
	scoreboard.text = "SCORE: " + str(score)

func _on_give_points(points):
	if player_alive:
		score = score + points
		set_score()
	
func _on_ShipSpawner_timeout():
	spawn_ship()


func _on_AsteroidSpawner_timeout():
	spawn_asteroid()


func _on_PlayerShip_player_ship_destroyed():
	player_alive= false
	$CenterContainer.visible = true
	if score > GlobalVars.high_score:
		GlobalVars.high_score = score
	$CenterContainer.set_high_score()

func _on_asteroid_hit():
	$AsteroidBreakSound.play()
