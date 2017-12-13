#!/usr/bin/env ruby

$LOAD_PATH << __FILE__ # '.'

require_relative "terminal_chess/version"
require_relative "printer.rb"
require_relative "move.rb"
require_relative "board.rb"

class LocalChessClient
  def initialize
    @board = Board.new
    @turn_by_turn_playback = []
    @board.display_board

    start
  end

  def start
    # Gameplay
    loop do
      if @board.checkmate
        puts "\nTurn by Turn Playback : #{@turn_by_turn_playback}\n"
        exit
      end

      print "\nPiece to Move [#{@board.player_turn.capitalize}]: "
      from = gets.chomp.upcase

      begin
        print "Valid destinations: #{@board.valid_destinations(from).join(", ")}"

        print "\nLocation: "
        to = gets.chomp.upcase
        @board.move(from, to)

      rescue Exception => e
        puts "Invalid selection #{e if !ENV["DEV"].nil?}"
      else
        @turn_by_turn_playback << [from, to]
      end
    end
  end
end

