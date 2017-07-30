#!/usr/bin/env ruby

$LOAD_PATH << __FILE__ #'.'

require_relative "terminal_chess/version"
require_relative "printer.rb"
require_relative "move.rb"
require_relative "board.rb"

# Setup
board = Board.new
board.setup_board 
board.board_refresh

# Gameplay
loop do

  print "\nPiece to Move [#{board.player_turn.capitalize}]: "
  from = gets.chomp.upcase
  
  begin
    print "Valid destinations: #{board.valid_destinations(from).join(", ")}"
  
    print "\nLocation: "
    to = gets.chomp.upcase
    board.move(from, to)

  rescue Exception => e
    puts "Invalid selection #{e if !ENV["DEV"].nil?}"
  end
end

