extends Node


var currentPlayer : Player 


func registerPlayer(player : Player):
	currentPlayer = player
	

func getPlayerPosition() -> Vector3:
	return currentPlayer.global_position
	
