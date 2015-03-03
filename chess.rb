#!/usr/bin/env ruby

load 'printer.rb'
load 'move.rb'
load 'board.rb'

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

