module TicTacToeModule

  # The Tic_Tac_Toe game squares
  class Square
    attr_reader :position
    attr_accessor :selected, :owner

    def initialize(number)
      @position = number
      @selected = false
      @owner = nil
    end

    def mark_selected(player_name)
      self.owner = player_name
      self.selected = true
    end

  end #  End class Square

  # A player in the game
  class Player
    attr_reader :name
    attr_accessor :winner

    def initialize(name)
      @name = name
      @winner = false
    end

  end #  End class Player

  # Player operated by a human user
  class User < Player

    def choose_square(squares, available_square_positions)
      all_positions = (1..9).to_a
      puts "Options:    ( 7 | 8 | 9 )"
      puts "            (--- --- ---)"
      puts "            ( 4 | 5 | 6 )"
      puts "            (--- --- ---)"
      puts "            ( 1 | 2 | 3 )"
      puts " "
      begin
        puts "#{@name}, please choose a square (1 through 9):"
        choice = gets.chomp.strip.to_i
        unless all_positions.include?(choice)
          raise ArgumentError.new("Selection was not of the correct format.")
        end
        unless available_square_positions.include?(choice)
          raise ArgumentError.new("Selection has already been chosen.")
        end
      rescue ArgumentError=>e
        puts "Error: #{e.message}"
        retry
      end
      chosen_square = squares.find { |square| square.position == choice }
      chosen_square.mark_selected(@name)
      puts "#{@name} has chosen square #{choice}."
    end

  end #  End class User

  # A Player automated by the computer
  class Computer < Player

    def choose_square(squares, available_square_positions)
      choice = available_square_positions.shuffle[0]
      chosen_square = squares.find { |square| square.position == choice }
      chosen_square.mark_selected(@name)
      puts "#{@name} has chosen square #{choice}."
    end

  end #  End class Computer

  # The main game mechanisim
  class TicTacToe

    WINNING_COMBOS = [  [7, 8, 9],
                        [4, 5, 6],
                        [1, 2, 3],
                        [1, 4, 7],
                        [2, 5, 8],
                        [3, 6, 9],
                        [1, 5, 9],
                        [3, 5, 7]  ]

    def initialize(player1, player2 = "NotSelected")
      @player1 = User.new(player1)
      # player2 is assigned as computer if no second name is passed
      if player2 == "NotSelected"
        @player2 = Computer.new("Computer")
      else
        @player2 = User.new(player2)
      end
      @squares = (1..9).map { |num| Square.new(num) }
      @game_won = false
    end

    # Randomly assigns the first turn
    def set_first_turn
      num = rand(2)
      num < 1 ? @player1 : @player2
    end

    # Initiates the game
    def play_game
      odd_player = set_first_turn
      even_player = (odd_player == @player1) ? @player2 : @player1
      round = 1
      # initialize the on-going game display
      puts " "
      puts "============================================"
      puts " "
      until (@game_won == true || get_available_square_positions.empty?)
        current_player = round.odd? ? odd_player : even_player
        current_player.choose_square(@squares, get_available_square_positions)
        @game_won = true if check_winner_exists
        update_game_display
        round += 1
      end
      if @game_won == true
        show_winner
      else
        puts "Tie Game! Nobody wins :( "
      end
    end

    # Returns the positions (1-9) currently available to players
    def get_available_square_positions
      available_squares = @squares.select { |square| square.selected == false }
      available_squares.map { |square| square.position }
    end

    # Returns the positions (1-9) currently owned by a player
    def get_player_square_positions(player_name)
      player_squares = @squares.select { |square| square.owner == player_name }
      player_squares.map { |square| square.position }
    end

    # Displays the current game board
    def update_game_display
      marks  = Hash[@squares.collect { |item| [item.position, item.owner] } ]
      marks.each do  |position, owner|
        case owner
        when @player1.name
          marks[position] = "X"
        when @player2.name
          marks[position] = "O"
        else
          marks[position] = " "
        end
      end

      puts " "
      puts " #{marks[7]} | #{marks[8]} | #{marks[9]} "
      puts "--- --- ---"
      puts " #{marks[4]} | #{marks[5]} | #{marks[6]} "
      puts "--- --- ---"
      puts " #{marks[1]} | #{marks[2]} | #{marks[3]} "
      puts " "
      puts "============================================"
      puts " "
    end

    # Returns true if there is a winner, and updates the winning player object
    def check_winner_exists
      require 'set'
      has_winner = false
      player1_positions = get_player_square_positions(@player1.name)
      player2_positions = get_player_square_positions(@player2.name)
      WINNING_COMBOS.each do |combo|
        if combo.to_set.subset?(player1_positions.to_set)
          @player1.winner = true
          has_winner = true
        elsif combo.to_set.subset?(player2_positions.to_set)
          @player2.winner = true
          has_winner = true
        end
      end
      return has_winner
    end

    # Displays the winner
    def show_winner
      if @player1.winner == true
        puts "#{@player1.name} Wins!!"
      elsif @player2.winner == true
        puts "#{@player2.name} Wins!!"
      else
        puts "Sorry, no winner yet"
      end
    end

  end #  End class TicTacToe

end #  End module TicTacToeModule
