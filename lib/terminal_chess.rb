#!/usr/bin/env ruby

$LOAD_PATH << '.'

require_relative "terminal_chess/version"
require_relative "printer.rb"
require_relative "move.rb"
require_relative "board.rb"

# Setup
a = Board.new; a.setup_board; a.board_refresh

# Gameplay
while true
  
  print "\nPiece to Move [#{a.player_turn.capitalize}]: "
  from = gets.chomp.upcase
  
  begin
    print "Valid destinations: #{a.valid_destinations(from).join(", ")}"
  
    print "\nLocation: "
    to = gets.chomp.upcase
    a.move(from, to)

  rescue Exception => e
    puts "Invalid selection"
  end
end

