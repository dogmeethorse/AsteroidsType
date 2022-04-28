extends Node2D

#export (PackedScene) var player_ship
export (PackedScene) var asteroids
export (PackedScene) var ships

var score = 0
var adding_score = true
var difficulty = 3
var current_spawn_location = 0
onready var spawns = [$SpawnPoint1, $SpawnPoint2, $SpawnPoint3, $SpawnPoint4, $SpawnPoint5, $SpawnPoint6] 
onready var scoreboard = $Score

# Called when the node enters the scene tree for the first time.
func _ready():
	for _i in range(difficulty):
		spawn_asteroid()

func spawn_asteroid():
	var new_asteroid = asteroids.instance()
	new_asteroid.position = spawns[current_spawn_location].position
	current_spawn_location = current_spawn_location + 1
	current_spawn_location = wrapf(current_spawn_location, 0, len(spawns)-1)
	add_child(new_asteroid)
	new_asteroid.connect("give_points", self, "_on_give_points")

func spawn_ship():
	var new_ship = ships.instance()
	new_ship.position = spawns[randi() % len(spawns)].position
	add_child(new_ship)
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
	if adding_score:
		score = score + points
		set_score()
	
func _on_ShipSpawner_timeout():
	spawn_ship()


func _on_AsteroidSpawner_timeout():
	spawn_asteroid()


func _on_PlayerShip_player_ship_destroyed():
	adding_score = false
	$CenterContainer.visible = true
