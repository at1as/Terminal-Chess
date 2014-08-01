#!/usr/bin/env ruby

load 'printer.rb'
load 'move.rb'
load 'board.rb'

# Setup
a = Board.new; a.setup_board; a.board_refresh

# Gameplay
while true
  
  print "\nPiece to Move: "
  from = gets.chomp.upcase
  
  begin
    print "Valid destinations: #{a.valid_destinations(from)}"
  
    print "\nLocation: "
    to = gets.chomp.upcase
    a.move(from, to)

  rescue
    puts "Invalid selection"
  end

end

