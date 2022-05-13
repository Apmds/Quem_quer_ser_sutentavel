extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.get_name() == "Android":
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, Vector2(1600, 720))
		OS.set_window_size(Vector2(1600, 720))
	SilentWolf.configure({
		"api_key": "F32KcPC9qa5ikqh2fxEFn9AOAO1DUmKt5QtAvcuh",
		"game_id": "Quemquersersustentavel",
		"game_version": "0.1.2",
		"log_level": 2})
	$AnimationPlayer.play("Normal")

# Play button
func _on_Play_button_pressed():
	get_tree().change_scene("res://Scenes/Game.tscn")

# Rankings button
func _on_Rankings_button_pressed():
	get_tree().change_scene("res://addons/silent_wolf/Scores/Leaderboard.tscn")

# Bug report
func _on_Bug_report_button_pressed():
	OS.shell_open("https://forms.gle/C5z3bUb135e4BJC56")

# Defenitions button
func _on_Defenitions_button_pressed():
	$AnimationPlayer.play("Defenitions_open")

# Defenitions back button
func _on_Back_button_pressed():
	$AnimationPlayer.play("Defenitions_close")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Defenitions_close":
		$AnimationPlayer.play("Normal")
	elif anim_name == "Defenitions_open":
		$Title.set_position(Vector2(220, 60))
		#$Title.rect_size = Vector2(732, 259)
		$Title.set_rotation(deg2rad(-10))
