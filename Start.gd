extends CenterContainer
var game_scene = "res://space.tscn"
onready var high_score_box = $VBoxContainer/HighScore
onready var master_sound = AudioServer.get_bus_index("Master")

func _ready():
	$VBoxContainer/CheckButton.set_pressed_no_signal(!AudioServer.is_bus_mute(master_sound))		

func _on_Button_pressed():
	var err = get_tree().change_scene(game_scene)
	if err:
		print_stack()

func set_high_score():
	high_score_box.text = "High Score: " + str(GlobalVars.high_score)


func _on_CheckButton_toggled(button_pressed):
	if button_pressed:
		AudioServer.set_bus_mute(master_sound, false)
	else:
		AudioServer.set_bus_mute(master_sound, true)
