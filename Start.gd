extends CenterContainer
var game_scene = "res://space.tscn"
onready var max_score_box = $VBoxContainer/MaxScore


func _on_Button_pressed():
	var err = get_tree().change_scene(game_scene)
	if err:
		print_stack()
