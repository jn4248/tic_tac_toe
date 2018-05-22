require 'set'

class Square
  attr_accessor :is_free, :owner

  def initialize(number)
    @position = number
    @selected = false
    @owner = nil
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

  def choose_square(selected_squares)
    options = %w{1 2 3 4 5 6 7 8 9}
    puts "Options:"
    puts " "
    puts "( 1 | 2 | 3 )"
    puts "(--- --- ---)"
    puts "( 4 | 5 | 6 )"
    puts "(--- --- ---)"
    puts "( 7 | 8 | 9 )"
    puts " "
    begin
      puts "#{@name}, please choose a square (1 through 9):"
      choice = gets.chomp.strip
      unless options.include?(choice)
        raise ArgumentError.new("Selection was not of the correct format.")
      end
      if selected_squares.include?(choice)
        raise ArgumentError.new("Selection has already been chosen.")
      end
    rescue ArgumentError=>e
      puts "Error: #{e.message}"
      retry
    end
    @my_squares.push(choice)
  end

end

class Computer < Player

  def choose_square(selected_squares)
    options = %w{1 2 3 4 5 6 7 8 9}
    available_squares = options - selected_squares
    choice = available_squares.shuffle[0]
    @my_squares.push(choice)
    puts "#{@name} has chosen square #{choice}."
  end

end

class Game
  attr_accessor :selected_squares

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
    @winning_combos = [ %w{1 2 3},
                        %w{4 5 6},
                        %w{7 8 9},
                        %w{1 4 7},
                        %w{2 5 8},
                        %w{3 6 9},
                        %w{1 5 9},
                        %w{3 5 7}  ]
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
      if round.odd?
        odd_player.choose_square(@selected_squares)
      else
        even_player.choose_square(@selected_squares)
      end
      update_selected_squares
      check_winner
      update_game_display
      @game_won = true if (@player1.winner == true || @player2.winner == true)
      round += 1
    end
    if round > 9
      puts "Tie Game! Nobody wins :( "
    else
      show_winner
    end
  end

  def update_selected_squares
    @selected_squares = @player1.my_squares + @player2.my_squares
  end

  def update_game_display
    marks_array = %w{1 2 3 4 5 6 7 8 9}
    marks  = Hash[marks_array.collect { |item| [item, " "] } ]
    @player1.my_squares.each do |square|
      marks[square.to_s] = "X"
    end
    @player2.my_squares.each do |square|
      marks[square.to_s] = "O"
    end

    puts " "
    puts " #{marks["1"]} | #{marks["2"]} | #{marks["3"]} "
    puts "--- --- ---"
    puts " #{marks["4"]} | #{marks["5"]} | #{marks["6"]} "
    puts "--- --- ---"
    puts " #{marks["7"]} | #{marks["8"]} | #{marks["9"]} "
    puts " "
    puts "==========================="
    puts " "
  end

  def check_winner
    player1_squares = @player1.my_squares.to_set
    player2_squares = @player2.my_squares.to_set
    @winning_combos.each_with_index do |combo, index|
      if combo.to_set.subset?(player1_squares)
        @player1.winner = true
      elsif combo.to_set.subset?(player2_squares)
        @player2.winner = true
      end
    end
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
