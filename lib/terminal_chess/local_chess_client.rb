#!/usr/bin/env ruby
# frozen_string_literal: true

#$LOAD_PATH << # '.'

require "terminal_chess/board"
require "terminal_chess/move"
require "terminal_chess/printer"
require "terminal_chess/version"

module TerminalChess
  # Chess client for each player to connect to webserver and play networked game
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
          print "Valid destinations: #{@board.valid_destinations(from).join(', ')}"

          print "\nLocation: "
          to = gets.chomp.upcase
          @board.move(from, to)
        rescue Exception => e
          puts "Invalid selection #{e unless ENV['DEV'].nil?}"
        else
          @turn_by_turn_playback << [from, to]
        end
      end
    end
  end
end
