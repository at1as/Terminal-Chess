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
  print "\nLocation: "
  to = gets.chomp.upcase
 
  begin
    a.move(from, to)
  rescue
    puts "Invalid Move. Try again"
  end

end
