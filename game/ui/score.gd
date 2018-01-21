extends HBoxContainer

onready var G = get_node("/root/game_state")


onready var score_value = get_node("score_value")

func _ready():
	set_score(G.player_score)
	pass
	
func update_score(brick_score):
	G.player_score += brick_score
	set_score( G.player_score )

func set_score( score ):
	score_value.set_text("%06d" % G.player_score)