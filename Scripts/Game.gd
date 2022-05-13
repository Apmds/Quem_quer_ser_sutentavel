extends Node2D

const two_answer_question = preload("res://Scenes/Questions/Question_2_answers.tscn")
const three_answer_question = preload("res://Scenes/Questions/Question_3_answers.tscn")
const four_answer_question = preload("res://Scenes/Questions/Question_4_answers.tscn")
const ROUNDS = 10
const BAD_WORDS = [
	
]
var RNG = RandomNumberGenerator.new()
var answered_questions = []
var current_question
var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	RNG.randomize()
	$Time/Text.text = str($Timer.wait_time)
	$Score/Text.text = "Pontos: " + str(score)
	$Rounds/Text.text = "Pergunta 1/" + str(ROUNDS)
	new_question()


func save_data(data, file, path = "res://"):
	# Criar e abrir um ficheiro
	var SAVE_PATH = path+file+'.json'
	var save_file = File.new()
	save_file.open(SAVE_PATH, File.WRITE)
	# Converter e guardar os dados para um formato usável
	save_file.store_line(to_json(data))
	# Fechar o ficheiro
	save_file.close()

func load_data(file, path = "res://"):
	# Criar e abrir um ficheiro
	var SAVE_PATH = path+file+".json"
	var save_file = File.new()
	# Retornar null se não existir esse ficheiro
	if not save_file.file_exists(SAVE_PATH):
		return null
	# Abrir o ficheiro
	save_file.open(SAVE_PATH, File.READ)
	# Obter os dados do ficheiro
	var data = parse_json(save_file.get_as_text())
	# Fechar o ficheiro
	save_file.close()
	# Retornar os dados
	return data

# Função para criar uma nova questão
func new_question():
	for node in $Questions.get_children():
		node.queue_free()
	# Obter uma questão aleatória do ficheiro "Questions" e verificar se já não foi perguntada
	var questions = load_data("Questions")
	var current_question_number = RNG.randi_range(0, len(questions)-1)
	if not current_question_number in answered_questions:
		answered_questions.append(current_question_number)
		current_question = questions.get(questions.keys()[current_question_number])
		# Criação de uma instância para uma pergunta
		var question_instance
		# Se for uma questão de 3 respostas
		if "3" in current_question[0]:
			question_instance = three_answer_question.instance()
			question_instance.get_node("Answers/Answer3/Text").text = current_question[4]
		
		# Se for uma questão de 4 respostas
		elif "4" in current_question[0]:
			question_instance = four_answer_question.instance()
			question_instance.get_node("Answers/Answer3/Text").text = current_question[4]
			question_instance.get_node("Answers/Answer4/Text").text = current_question[5]
		
		# Se for uma questão de 2 respostas
		elif "2" in current_question[0]:
			question_instance = two_answer_question.instance()
		
		# Mudanças nas labels comuns às questões de 2, 3 e 4 questões
		question_instance.get_node("Question/Text").text = questions.keys()[current_question_number]
		question_instance.get_node("Answers/Answer1/Text").text = current_question[2]
		question_instance.get_node("Answers/Answer2/Text").text = current_question[3]
		question_instance.connect("answered_right", self, "_on_Question_answered_right")
		question_instance.connect("answered_wrong", self, "_on_Question_answered_wrong")
		question_instance.correct_answer = current_question[1]
		$Questions.add_child(question_instance)
		$AnimationPlayer.play("Enter_question")
	
	else:
		new_question()
		return null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Time/Text.text = str(ceil($Timer.time_left))

# Quando o tempo acaba
func _on_Timer_timeout():
	end_game()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Exit_question":
		if len(answered_questions) != ROUNDS:
			new_question()
		else:
			end_game()
	elif anim_name == "Enter_question":
		$Rounds/Text.text = "Pergunta " + str(len(answered_questions)) + "/" + str(ROUNDS)
		$Timer.start()
		set_process(true)

# Se a resposta for acertada
func _on_Question_answered_right():
	score += 2
	$Score/Text.text = "Pontos: " + str(score)
	$AnimationPlayer.play("Exit_question")
	set_process(false)
	$Timer.stop()

# Se a resposta for errada
func _on_Question_answered_wrong(right_answer):
	if right_answer != -1:
		score -= 1
		$Score/Text.text = "Pontos: " + str(score)
		$AnimationPlayer.play("Exit_question")
		set_process(false)
		$Timer.stop()

# Se a jogo for perdido
func end_game():
	$Questions.visible = false
	$Time/Text.text = "0"
	if score > 0:
		$End_Screen/Title.text = "A tua pontuação: " + str(score)
	else:
		$End_Screen/Title.text = "A tua pontuação: –" + str(abs(score))
	$End_Screen.visible = true
	set_process(false)
	$Timer.stop()

# Quando o botão para confirmar o nome é pressionado
func _on_Confirm_button_pressed():
	var player_name = $End_Screen/LineEdit.text
	# Detetar conteúdo impróprio no nome
	for word in load_data("Bad words")["words"]:
		if word in player_name.to_lower().replace(" ", ""):
			set_end_screen_error_text("O teu nome contém conteúdo inválido.")
	# Verificar se o tamanho do nome é correto
	if len(player_name) > 25:
		set_end_screen_error_text("O teu nome é muito comprido!")
	elif len(player_name) < 3:
		set_end_screen_error_text("O teu nome tem de ter no mínimo 3 caracteres.")
	# O nome tem o tamanho correto e não tem conteúdo impróprio
	else:
		# Adicionar o nome ao painel de líderes
		yield(SilentWolf.Scores.persist_score(player_name, score), "sw_score_posted")
		yield(SilentWolf.Scores.get_high_scores(), "sw_scores_received")
		get_tree().change_scene("res://addons/silent_wolf/Scores/Leaderboard.tscn")

# Função para alterar o texto de erro no menu de confirmação do nome
func set_end_screen_error_text(text):
	$End_Screen/Name_error.text = text
	$End_Screen/Name_error.visible = true
	yield(get_tree().create_timer(1.5), "timeout")
	$End_Screen/Name_error.visible = false
