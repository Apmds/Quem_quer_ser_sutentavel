extends Control


var RNG = RandomNumberGenerator.new()
var correct_answer
signal answered_right
signal answered_wrong(right_answer)

# Called when the node enters the scene tree for the first time.
func _ready():
	RNG.randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_Answer1_pressed():
	for answer in $Answers.get_children():
		answer.get_node("Button").disabled = true
	$Answers.get_children()[correct_answer-1].self_modulate = Color(0.11, 0.98, 0.1)
	if correct_answer == 1:
		print("Resposta certa!")
		emit_signal("answered_right")
	else:
		print("Resposta errada!")
		$Answers/Answer1.self_modulate = Color(0.96, 0.22, 0.04)
		emit_signal("answered_wrong", correct_answer)


func _on_Answer2_pressed():
	for answer in $Answers.get_children():
		answer.get_node("Button").disabled = true
	$Answers.get_children()[correct_answer-1].self_modulate = Color(0.11, 0.98, 0.1)
	if correct_answer == 2:
		print("Resposta certa!")
		emit_signal("answered_right")
	else:
		print("Resposta errada!")
		$Answers/Answer2.self_modulate = Color(0.96, 0.22, 0.04)
		emit_signal("answered_wrong", correct_answer)
