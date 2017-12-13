#!/usr/bin/env ruby

load 'printer.rb'
load 'move.rb'
load 'terminal_chess/messages.rb'
require 'colorize'

class Board

  include Printer
  include Move

  attr_reader :piece_locations, :checkmate, :player_turn
  attr_reader :taken_pieces

  alias piece_manifest piece_locations


  def initialize
    @piece_locations_buffer = Hash.new
    @piece_locations = Hash.new
    @row_mappings    = Hash[("A".."H").zip(1..8)]
    @taken_pieces    = Array.new
    @player_turn     = :black
    @checkmate       = false

    setup_board
  end

  # Game logic
  def move(p1, p2)

    manifest = piece_manifest()

    p1 = get_index_from_rowcol(p1.to_s)
    p2 = get_index_from_rowcol(p2.to_s)

    # Find valid positions and subtract king current position as nobody can directly take king piece
    valid_positions = possible_moves(p1, manifest, true)
    valid_positions -= king_positions

    # If player is moving out of turn, display message
    # `return p ...` is so we print value and return it from the function
    #  this is so the unit tests can get the value directly. There are better ways to do this
    unless @player_turn == @piece_locations[p1][:color]
      return p "It is #{@player_turn}'s turn. Please move a #{@player_turn} piece."
    end

    return p "Please select a valid destination." unless valid_positions.include?(p2)

    create_board_after_piece_moved(p1, p2)

    # If player is in check with the new proposed board, disallow the movement
    if check?(@player_turn, @piece_locations_buffer)
      return p "Please move #{@player_turn} king out of check to continue"
    end

    # At this point, the move appears to be valid
    @taken_pieces << @piece_locations[p2] unless @piece_locations[p2][:type].nil?

    # Check for Pawn Promotion (if pawn reaches end of the board, promote it)
    if @piece_locations_buffer[p2][:type] == :pawn
      if p2 < 9 && @piece_locations_buffer[p2][:color] == :red
        promote(p2)
      elsif p2 > 56 && @piece_locations_buffer[p2][:color] == :black
        promote(p2)
      end
    end

    # Check for Castling - https://en.m.wikipedia.org/wiki/Castling
    if @piece_locations_buffer[p2][:type] == :king && (p2 - p1).abs == 2

      p2 < 9 ? y_offset = 0 : y_offset = 56

      if p2 > p1
        @piece_locations_buffer[6+y_offset] = @piece_locations_buffer[8+y_offset]
        @piece_locations_buffer[8+y_offset] = {
          :type   => nil,
          :number => nil,
          :color  => nil
        }
      else
        @piece_locations_buffer[4+y_offset] = @piece_locations_buffer[1+y_offset]
        @piece_locations_buffer[1+y_offset] = {
          :type   => nil,
          :number => nil,
          :color  => nil
        }
      end
    end

    commit_board_piece_movement

    if (winner = player_in_checkmate(@piece_locations))
      return p Messages.black_winner if winner == :black
      return p Messages.red_winner   if winner == :red
    end

    return p Messages.piece_moved
  end


  def commit_board_piece_movement
    @piece_locations = @piece_locations_buffer
    @player_turn = opposing_color(@player_turn)
    display_board
  end


  def create_board_after_piece_moved(p1, p2)
    # Store state of board after proposed move in @piece_locations_buffer
    @piece_locations_buffer = @piece_locations.clone
    @piece_locations_buffer[p2] = @piece_locations_buffer[p1]
    @piece_locations_buffer[p2][:moved] = true
    @piece_locations_buffer[p1] = {
      :type   => nil,
      :number => nil,
      :color  => nil
    }
  end


  # Return the valid positions for piece at current_pos to move in readable format [A-H][1-8]
  def valid_destinations(current_pos)
    readable_positions = []
    manifest = piece_manifest
    p1 = get_index_from_rowcol(current_pos.to_s)

    valid_positions = possible_moves(p1, manifest, true)

    valid_positions.each do |pos|
      grid_pos = get_rowcol_from_index(pos)
      # Map first string character 1-8 to [A-H], for column, and then add second string character as [1-8]
      readable_positions << (@row_mappings.key(grid_pos[0].to_i) + grid_pos[1].to_s)
    end

    readable_positions.sort
  end


  # Search piece manifest for kings. Remove them from the list of positions returned
  # from the Move module (so that players cannot take the "king" type piece)
  def king_positions
    king_locations = []

    @piece_locations.each do |piece, details|
      king_locations << piece if details.fetch(:type) == :king
    end

    king_locations
  end


  # Once a pawn reaches the end, this method is called to swap the pawn
  # for another piece (from the list below)
  def promote(p1)
    puts "Promote to: [Q]ueen, [K]night, [R]ook, [B]ishop"

    loop do
      promo_piece = gets.chomp.downcase

      if promo_piece == "q" || promo_piece == :queen
        @piece_locations_buffer[p1][:type] = :queen
        break

      elsif promo_piece == "k" || promo_piece == :knight
        @piece_locations_buffer[p1][:type] = :knight
        break

      elsif promo_piece == "r" || promo_piece == :rook
        @piece_locations_buffer[p1][:type] = :rook
        break

      elsif promo_piece == "b" || promo_piece == :bishop
        @piece_locations_buffer[p1][:type] = :bishop
        break

      else
        puts "Please enter one of: [Q]ueen, [K]night, [R]ook, [B]ishop"
      end
    end
  end

  private :promote


  def player_in_checkmate(manifest = @piece_locations)
    return :red   if checkmate?(:black, manifest)
    return :black if checkmate?(:red,   manifest)
  end

  def checkmate?(color, manifest)
    check?(color, manifest, recurse_for_checkmate=true) && @checkmate
  end

  # Return whether the player of a specified color has their king currently in check
  # by checking the attack vectors of all the opponents players against the king location
  # Also, check whether king currently in check, has all of their valid moves within
  # their opponents attack vectors, and therefore are in checkmate (@checkmate)
  def check?(color, proposed_manifest = @piece_locations, recurse_for_checkmate = false)

    enemy_attack_vectors  = {}
    player_attack_vectors = {}

    king_loc    = []
    enemy_color = opposing_color(color)

    proposed_manifest.each do |piece, details|

      if details[:color] == enemy_color
        enemy_attack_vectors[piece] = possible_moves(piece, proposed_manifest)

      elsif details[:color] == color
        begin
          player_attack_vectors[piece] = possible_moves(piece, proposed_manifest)
        rescue
          # TODO: Fix possible_moves() so it doesn't throw exceptions
          # This happens because it is searching board for where pieces
          # will be, as as a result some pieces are nil
        end
      end

      king_loc = piece if details[:color] == color && details[:type] == :king
    end

    danger_vector  = enemy_attack_vectors.values.flatten.uniq
    defence_vector = player_attack_vectors.values.flatten.uniq
    king_positions = possible_moves(king_loc, proposed_manifest)

    # The King is in the attackable locations by the opposing player
    return false unless danger_vector.include? king_loc

    # If all the positions the king piece can move to is also attackable by the opposing player
    if recurse_for_checkmate && ((king_positions - danger_vector).length == 0)

      is_in_check = []
      player_attack_vectors.each do |piece_index, piece_valid_moves|
        piece_valid_moves.each do |possible_new_location|

          # Check if board is still in check after piece moves to its new location
          @new_piece_locations = @piece_locations.clone
          @new_piece_locations[possible_new_location] = @new_piece_locations[piece_index]
          @new_piece_locations[piece_index] = {
            :type   => nil,
            :number => nil,
            :color  => nil
          }

          is_in_check << check?(color, @new_piece_locations)
        end
      end

      if is_in_check.include?(false)
        return false
      else
        @checkmate = true
      end
    end

    true
  end


  def opposing_color(player_color)
    ([:black, :red] - [player_color]).first
  end

  # Board spaces that are attackable by opposing pieces
  #  TODO: check? method should use this function
  def attack_vectors(color = @player_turn, proposed_manifest = @piece_locations)
    enemy_color = opposing_color(color)
    kill_zone = Array.new

    proposed_manifest.each do |piece, details|
      kill_zone << possible_moves(piece, proposed_manifest) if details.fetch(:color) == enemy_color
    end

    kill_zone.flatten.uniq
  end


  # Reprint the board. Called after every valid piece move
  def display_board
    print_board @piece_locations
  end


  # Convert index [A-H][1-8] => (1 - 64)
  def get_index_from_rowcol(row_col)
    (row_col[1].to_i - 1) * 8 + @row_mappings.fetch(row_col[0]).to_i
  end


  # Convert index (1 - 64) => [A-H][1-8]
  def get_rowcol_from_index(index)
    letter = get_col_from_index(index)
    number = get_row_from_index(index)

    "#{letter}#{number}"
  end


  def setup_board
    # Intial setup of board. Put pieces into the expected locations
    setup_empty_tiles
    place_player_pieces(:black)
    place_player_pieces(:red)
  end


  def setup_empty_tiles
    # Initialize chess board tiles without any pieces
    (1..64).each do |tile_num|
      @piece_locations[tile_num] = {
        :type   => nil,
        :number => nil,
        :color  => nil
      }
    end
  end


  def place_player_pieces(color)
    # Place pieces on chess board
    place_first_row(color)
    place_pawns(color)
  end


  def place_pawns(color)
    offset = color == :black ? 8 : 48

    (1..8).each do |piece_num|
      @piece_locations[piece_num + offset] = {
        :type   => :pawn,
        :number => piece_num,
        :color  => color,
        :moved  => false
      }
    end
  end


  def place_first_row(color)
    row_offset = color == :black ? 0 : 56

    @piece_locations[row_offset + 1] = {:type => :rook,   :number => 1, :color => color, :moved => false}
    @piece_locations[row_offset + 2] = {:type => :knight, :number => 1, :color => color, :moved => false}
    @piece_locations[row_offset + 3] = {:type => :bishop, :number => 1, :color => color, :moved => false}
    @piece_locations[row_offset + 4] = {:type => :queen,  :number => 1, :color => color, :moved => false}
    @piece_locations[row_offset + 5] = {:type => :king,   :number => 1, :color => color, :moved => false}
    @piece_locations[row_offset + 6] = {:type => :bishop, :number => 2, :color => color, :moved => false}
    @piece_locations[row_offset + 7] = {:type => :knight, :number => 2, :color => color, :moved => false}
    @piece_locations[row_offset + 8] = {:type => :rook,   :number => 2, :color => color, :moved => false}
  end

end
