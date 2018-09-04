require "./tic_tac_toe"

# Play single-player game, one user against the computer
game = TicTacToeModule::TicTacToe.new("Jason")
game.play_game

# Play 2-player game, with two users
# game = TicTacToe.new("Jason", "Betty")
# game.play_game
