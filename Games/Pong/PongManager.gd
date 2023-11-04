extends Node2D

var player_score: int :
	set(score):
		player_score = score
		$"Player Score Text".text = str(score)
var enemy_score: int :
	set(score):
		enemy_score = score
		$"Enemy Score Text".text = str(score)
