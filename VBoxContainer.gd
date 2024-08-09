extends VBoxContainer

const lab = preload("res://level_2.tscn")
const fight = preload("res://Level.tscn")

func _on_play_pressed():
	get_tree().change_scene_to_packed(lab)

func _on_practise_pressed():
	get_tree().change_scene_to_packed(fight)
	
func _on_quit_pressed():
	get_tree().quit()
