
class Square
  attr_accessor :position, :selected, :owner

  def initialize(number)
    @position = number
    @selected = false
    @owner = nil
  end

  def mark_selected(player_name)
    self.owner = player_name
    self.selected = true
  end

end


class Player
  attr_reader :my_squares, :name
  attr_accessor :play_odd_rounds, :winner

  def initialize(name)
    @name = name
    @winner = false
    @my_squares = []
  end

end

class User < Player

  def choose_square(squares, available_square_positions)
    all_positions = (1..9).to_a
    puts "Options:"
    puts " "
    puts "( 7 | 8 | 9 )"
    puts "(--- --- ---)"
    puts "( 4 | 5 | 6 )"
    puts "(--- --- ---)"
    puts "( 1 | 2 | 3 )"
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
    puts "chosen_square is class: " + chosen_square.class.to_s
    chosen_square.mark_selected(@name)
    puts "Chose square " + chosen_square.position.to_s
    puts "chosen square owner = " + chosen_square.owner.to_s
    puts "chosen square selected? = " + chosen_square.selected.to_s
    puts "end of choose_square"
    puts " "
    puts "#{@name} has chosen square #{choice}."
  end

end

class Computer < Player

  def choose_square(squares, available_square_positions)
    choice = available_square_positions.shuffle[0]
    chosen_square = squares.find { |square| square.position == choice }
    chosen_square.mark_selected(@name)
    puts "Chose square " + chosen_square.position.to_s
    puts "chosen square owner = " + chosen_square.owner.to_s
    puts "chosen square selected? = " + chosen_square.selected.to_s
    puts "end of choose_square"
    puts " "
    puts "#{@name} has chosen square #{choice}."
  end

end

class Game
  attr_accessor :selected_squares

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
    if player2 == "NotSelected"
      @player2 = Computer.new("Computer")
    else
      @player2 = User.new(player2)
    end
    @squares = (1..9).map { |num| Square.new(num) }
    @selected_squares = []
    @game_won = false
  end

  def set_first_turn
    num = rand(2)
    num < 1 ? @player1 : @player2
  end

  def play_game
    odd_player = set_first_turn
    even_player = (odd_player == @player1) ? @player2 : @player1
    round = 1
    until (@game_won == true || round > 9)
      current_player = round.odd? ? odd_player : even_player
      current_player.choose_square(@squares, get_available_square_positions)
      @game_won = true if check_winner_exists
      update_game_display
      round += 1
    end
    if round > 9
      puts "Tie Game! Nobody wins :( "
    else
      show_winner
    end
  end

  def get_available_square_positions
    available_squares = @squares.select { |square| square.selected == false }
    available_squares.map { |square| square.position }
  end

  def get_player_square_positions(player_name)
    player_squares = @squares.select { |square| square.owner == player_name }
    player_squares.map { |square| square.position }
  end


  def update_game_display
    marks  = Hash[@squares.collect { |item| [item.position, item.owner] } ]
    marks.each do  |position, owner|
      puts "display: position = " + position.to_s
      puts "display: owner = " + owner.to_s
      case owner
      when @player1.name
        # owner = "X"
        marks[position] = "X"
        puts "assigned X for P1"
      when @player2.name
        # owner = "O"
        marks[position] = "O"
        puts "assigned O for P2"
      else
        # owner = " "
        marks[position] = " "
        puts "assigned 'space' to nobody"
      end
      puts "End of display EACH block"
    end




    puts " "
    puts " #{marks[7]} | #{marks[8]} | #{marks[9]} "
    puts "--- --- ---"
    puts " #{marks[4]} | #{marks[5]} | #{marks[6]} "
    puts "--- --- ---"
    puts " #{marks[1]} | #{marks[2]} | #{marks[3]} "
    puts " "
    puts "==========================="
    puts " "
  end

  def check_winner_exists
    require 'set'
    has_winner = false
    player1_positions = get_player_square_positions(@player1.name)
    puts "p1 current positions:"
    p player1_positions
    player2_positions = get_player_square_positions(@player2.name)
    puts "p2 current positions:"
    p player2_positions
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

  def show_winner
    if @player1.winner == true
      puts "#{@player1.name} Wins!!"
    elsif @player2.winner == true
      puts "#{@player2.name} Wins!!"
    else
      puts "Sorry, no winner yet"
    end
  end

end

play = Game.new("Betty")
play.play_game
