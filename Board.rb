#!/usr/bin/env ruby

load 'printer.rb'
load 'move.rb'
require 'colorize'

class Board

  include PRINTER
  include MOVE

  def initialize
    @@piece_locations = Hash.new
    @@row_mappings = {"A" => 1, "B" => 2, "C" => 3, "D" => 4,
                        "E" => 5, "F" => 6, "G" => 7, "H" => 8}
    @@taken_pieces = []
    @@player_turn = "black"
    @@checkmate = false
  end


  # The game logic
  def move(p1, p2)
    manifest = piece_manifest
    p1 = get_index_from_rowcol(p1.to_s)
    p2 = get_index_from_rowcol(p2.to_s)
    valid_positions = possible_moves(p1, manifest)

    ##Subtract king current position from valid positions
    valid_positions -= king_positions
    if !@@checkmate
      puts "CM??"
      puts !@@checkmate
      puts "</CM??"
      if @@player_turn == @@piece_locations[p1]["color"]
        if !check?(@@player_turn) || (@@piece_locations[p1]["color"] == @@player_turn && @@piece_locations[p1]["type"] == "king")
          puts "#{@@player_turn}"
          puts "#{@@piece_locations[p1]['color']}"
          puts "#{@@player_turn == @@piece_locations[p1]["color"]}"
          puts "Checkmate: #{@@checkmate}"
          if ([p2] - valid_positions).empty?
            @@taken_pieces << @@piece_locations[p2] if !@@piece_locations[p2]["number"].nil?
            @@piece_locations[p2] = @@piece_locations[p1]
            @@piece_locations[p2]["moved"] = true

            # Special case for pawn
            if @@piece_locations[p2]["type"] == "pawn"

              # If a pawn reaches the end rows of the board, promote it to a new piece
              if p2 < 9 && @@piece_locations[p2]["color"] == "red"
                promote(p2)
              elsif p2 > 56 && @@piece_locations[p2]["color"] == "black"
                promote(p2)
              end
            end

            # Old location of the piece is now cleared
            @@piece_locations[p1] = {"type" => "  ", "number" => nil, "color" => nil}

            # Set it to the other player's turn
            @@player_turn = (["black", "red"] - [@@player_turn]).first

            board_refresh
          end

          puts "\nValid Positions #{valid_positions}"
        else
          "Your king is in check. Please move the #{@@player_turn} king out of check"
        end
      else
        puts "It is #{@@player_turn}'s turn. Please move a #{@@player_turn} piece."
      end
    else
      puts "Checkmate! Game Over."
    end
  end

  # Search piece manifest for kings. Remove them from the list of positions returned
  # from the MOVE module (so that players cannot take the "king" type piece)
  def king_positions
    king_locations = []
    @@piece_locations.each do |piece, details|
      if details["type"] == "king"
        king_locations << piece
      end
    end
    return king_locations
  end


  # Once a pawn reaches the end, this method is called to swap the pawn
  # for another piece (from the list below)
  def promote(p1)
    puts "Promote to: [Q]ueen, [K]night, [R]ook, [B]ishop"
    promo_piece = gets.chomp.downcase
    if promo_piece == "q" || promo_piece == "queen"
      @@piece_locations[p1]["type"] = "queen"
    elsif promo_piece == "k" || promo_piece == "knight"
      @@piece_locations[p1]["type"] = "knight"
    elsif promo_piece == "r" || promo_piece == "rook"
      @@piece_locations[p1]["type"] = "rook"
    elsif promo_piece == "b" || promo_piece == "bishop"
      @@piece_locations[p1]["type"] = "bishop"
    end
  end


  # Return whether the player of a specified color has their king currently in check
  # by checking the attack vectors of all the opponents players, versus the king location
  # Also, check whether king currently in check, has all of their valid moves within
  # their opponents attack vectors, and therefore are in checkmate (@@checkmate)
  def check?(color)
    path, king_loc = [], []
    manifest = piece_manifest
    enemy_color = (["black", "red"] - ["#{color}"]).first

    @@piece_locations.each do |piece, details|
      if details["color"] == enemy_color
        path << possible_moves(piece, manifest)
      end
      if details["color"] == color && details["type"] == "king"
        king_loc = piece
      end
    end
    puts "P1: #{king_loc}"
    puts "PATH: #{path.flatten.uniq}"
    danger_vector = path.flatten.uniq
    king_positions = possible_moves(king_loc, manifest)

    # If the King is in the attackable locations for the opposing player
    if danger_vector.include? king_loc
      # If all the positions the can move to is also attackable by the opposing player
      if (king_positions - danger_vector).length != 0
        @@checkmate = true
      end
      # Piece is in check
      return true
    else
      # Piece is not in check
      return false
    end
  end


  # Reprint the board. Called after every valid piece move
  def board_refresh
    print_board(@@piece_locations)
  end


  # Convert this notation "B4" to this notation "12"
  # [A-H][1-8] = (1 to 64)
  def get_index_from_rowcol(row_col)
    offset = @@row_mappings[row_col[0]].to_i
    multiplier = row_col[1].to_i - 1
    return multiplier * 8 + offset
  end


  # Intial setup of board. Put pieces into the expected locations
  def setup_board
    (1..64).each do |location|
      @@piece_locations[location] = {"type" => "  ", "number" => nil, "color" => nil}
    end

    # Black Pieces
    @@piece_locations[1] = {"type" => "rook", "number" => 1, "color" => "black", "moved" => false}
    @@piece_locations[2] = {"type" => "knight", "number" => 1, "color" => "black", "moved" => false}
    @@piece_locations[3] = {"type" => "bishop", "number" => 1, "color" => "black", "moved" => false}
    @@piece_locations[4] = {"type" => "queen", "number" => 1, "color" => "black", "moved" => false}
    @@piece_locations[5] = {"type" => "king", "number" => 1, "color" => "black", "moved" => false}
    @@piece_locations[6] = {"type" => "bishop", "number" => 2, "color" => "black", "moved" => false}
    @@piece_locations[7] = {"type" => "knight", "number" => 2, "color" => "black", "moved" => false}
    @@piece_locations[8] = {"type" => "rook", "number" => 2, "color" => "black", "moved" => false}
    (1..8).each do |col|
      @@piece_locations[col + 8] = {"type" => "pawn", "number" => col, "color" => "black", "moved" => false}
    end

    # White Pieces
    @@piece_locations[57] = {"type" => "rook", "number" => 1, "color" => "red", "moved" => false}
    @@piece_locations[58] = {"type" => "knight", "number" => 1, "color" => "red", "moved" => false}
    @@piece_locations[59] = {"type" => "bishop", "number" => 1, "color" => "red", "moved" => false}
    @@piece_locations[60] = {"type" => "queen", "number" => 1, "color" => "red", "moved" => false}
    @@piece_locations[61] = {"type" => "king", "number" => 1, "color" => "red", "moved" => false}
    @@piece_locations[62] = {"type" => "bishop", "number" => 2, "color" => "red", "moved" => false}
    @@piece_locations[63] = {"type" => "knight", "number" => 2, "color" => "red", "moved" => false}
    @@piece_locations[64] = {"type" => "rook", "number" => 2, "color" => "red", "moved" => false}
    (1..8).each do |col|
      @@piece_locations[col + 48] = {"type" => "pawn", "number" => col, "color" => "red", "moved" => false}
    end
  end


  # Below here is mainly for testing purposes
  def piece_manifest
    return @@piece_locations
  end

  def taken_pieces
    return @@taken_pieces
  end

  def checkmate?
    return @@checkmate
  end

  def player_turn
    return @@player_turn
  end

end