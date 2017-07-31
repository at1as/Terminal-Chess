#!/usr/bin/env ruby

module Move

  NULL_TYPE = "  "

  def constants(piece_mapping, color, piece)
    @@pieces = piece_mapping
    @@color  = color
    @@type   = piece
    @@enemy_color = (["black", "red"] - ["#{color.downcase}"]).first
  end


  # Calls methods below to return a list of positions which are valid moves
  # for piece at index p1, given the current board layout as defined in manifest
  def possible_moves(p1, manifest, castling = false)
    allowed   = []

    return [] if manifest[p1][:type] == NULL_TYPE

    type      = manifest[p1][:type]
    my_color  = manifest[p1][:color]

    constants(manifest, my_color, type)
    
    unless unoccupied?(p1)

      if type == "king"
        allowed += [move_lateral(p1, 1)].flatten
        allowed += [move_diagonal(p1, 1)].flatten
        allowed += [castle(p1)].flatten if castling

      elsif type == "queen"
        allowed += [move_lateral(p1)].flatten
        allowed += [move_diagonal(p1)].flatten

      elsif type == "rook"
        allowed += [move_lateral(p1)].flatten

      elsif type == "bishop"
        allowed += [move_diagonal(p1)].flatten

      elsif type == "pawn"
        allowed += [move_pawn(p1)].flatten

      elsif type == "knight"
        allowed += [move_knight(p1)].flatten
      end
    end
    
    return allowed
  end


  # Returns all valid positions a pawn at index p1 can move to
  def move_pawn(p1)
    row = get_row_from_index(p1)
    col = get_col_from_index(p1)
    valid = []

    # Piece color defines direction of travel. Enemy presence defines
    # the validity of diagonal movements
    if @@color == "red"
      if unoccupied?(p1 - 8)
        valid << (p1 - 8)
      end
      if piece_color(p1 - 7) == @@enemy_color && col < 8
        valid << (p1 - 7)
      end
      if piece_color(p1 - 9) == @@enemy_color && col > 1
        valid << (p1 - 9)
      end
      # Only if the pieces is unmoved, can it move forward two rows
      if !@@pieces[p1][:moved] && unoccupied?(p1 - 8) && unoccupied?(p1 - 16)
        valid << (p1 - 16)
      end
    
    elsif @@color == "black"
      
      if unoccupied?(p1 + 8)
        valid << (p1 + 8)
      end
      if piece_color(p1 + 7) == @@enemy_color && col > 1
        valid << (p1 + 7)
      end
      if piece_color(p1 + 9) == @@enemy_color && col < 8
        valid << (p1 + 9)
      end
      if !@@pieces[p1][:moved] && unoccupied?(p1 + 8) && unoccupied?(p1 + 16)
        valid << (p1 + 16)
      end
    end

    valid
  end


  # Returns valid positions a knight at index p1 can move to
  def move_knight(p1)
    row = get_row_from_index(p1)
    col = get_col_from_index(p1)

    valid = []
    valid_moves_no_friendly_fire = []

    # Valid knight moves based on its board position
    if row < 7 && col < 8
      valid << (p1 + 17)
    end
    if row < 7 && col > 1
      valid << (p1 + 15)
    end
    if row < 8 && col < 7
      valid << (p1 + 10)
    end
    if row < 8 && col > 2
      valid << (p1 + 6)
    end
    if row > 1 && col < 7
      valid << (p1 - 6)
    end
    if row > 1 && col > 2
      valid << (p1 - 10)
    end
    if row > 2 && col < 8
      valid << (p1 - 15)
    end
    if row > 2 && col > 1
      valid << (p1 - 17)
    end

    # All possible moves for the knight based on board boundaries will added
    # This iterator filters for friendly fire, and removes indexes pointing to same color pices
    valid.each do |pos|
      unless piece_color(pos) == @@color
        valid_moves_no_friendly_fire << pos
      end
    end

    valid_moves_no_friendly_fire
  end


  # Lateral movements (Left, Right, Up, Down). Will return all valid lateral movies for a piece at index
  # By default, it will extend the piece movement laterally until it hits a board edge
  # or until it hits a piece. This can be changed by passing the limit argument
  # For example, the king can only move laterally 1 position, so it would pass limit=1
  def move_lateral(index, limit = 8)
    row = get_row_from_index(index)
    col = get_col_from_index(index)

    left, right = [col-1, limit].min, [8-col, limit].min
    up, down = [row-1, limit].min, [8-row, limit].min
    
    valid = []

    # Move down N places until board limit, piece in the way, or specified limit
    down.times do |i|
        next_pos = index + (i+1)*8
        # Valid move if position is unoccupied
        if unoccupied?(next_pos)
          valid << next_pos
        else
          # Valid move is piece is an enemy, but then no subsequent tiles are attackable
          # if the piece is not an enemy, it's not added as a valid move, and no subsequent tiles are attackable
          # This function doesn't filter out the king from a valid enemy, but the Board class will drop King indexes
          if piece_color(next_pos) == @@enemy_color
            valid << next_pos
          end

          break
        end
    end

    # Move up N places until board limit, piece in the way, or specified limit
    up.times do |i|
        next_pos = index - (i+1)*8
        if unoccupied?(next_pos)
          valid << next_pos
        else
          if piece_color(next_pos) == @@enemy_color
            valid << next_pos
          end
          break
        end
    end

    # Move right N places until board limit, piece in the way, or specified limit
    right.times do |i|
        next_pos = index + (i+1)
        if unoccupied?(next_pos)
          valid << next_pos
        else
          if piece_color(next_pos) == @@enemy_color
            valid << next_pos
          end
          break
        end
    end

    # Move left N places until board limit, piece in the way, or specified limit
    left.times do |i|
        next_pos = index - (i+1)
        if unoccupied?(next_pos)
          valid << next_pos
        else
          if piece_color(next_pos) == @@enemy_color
            valid << next_pos
          end
          break
        end
    end
    
    valid
  end


  # Diagonal movements. Will return all valid diagonal movies for a piece at index
  # By default, it will extend the piece movement diagonally until it hits a board edge
  # or until it hits a piece. This can be changed by passing the limit argument
  # For example, the king can only move diagonally 1 position, so it would pass limit=1
  def move_diagonal(index, limit = 8)

    row = get_row_from_index(index)
    col = get_col_from_index(index)
    left, right = [col-1, limit].min, [8-col, limit].min
    up, down = [row-1, limit].min, [8-row, limit].min
    valid = []

    # up and to the right
    ([up, right, limit].min).times do |i|
      next_pos = index - (i+1)*7
      # Valid move if position is unoccupied
      if unoccupied?(next_pos)
        valid << next_pos
      else
        # Valid move is piece is an enemy, but then no subsequent tiles are attackable
        # if the piece is not an enemy, it's not added as a valid move, and no subsequent tiles are attackable
        # This function doesn't filter out the king from a valid enemy, but the Board class will drop King indexes
        if piece_color(next_pos) == @@enemy_color
          valid << next_pos
        end
        break
      end
    end

    # up and to the left
    ([up, left, limit].min).times do |i|
      next_pos = index - (i+1)*9
      if unoccupied?(next_pos)
        valid << next_pos
      else
        if piece_color(next_pos) == @@enemy_color
          valid << next_pos
        end
        break
      end
    end

    # down and to the right
    ([down, right, limit].min).times do |i|
      next_pos = index + (i+1)*9
      if unoccupied?(next_pos)
        valid << next_pos
      else
        if piece_color(next_pos) == @@enemy_color
          valid << next_pos
        end
        break
      end
    end

    # down and to the left
    ([down, left, limit].min).times do |i|
      next_pos = index + (i+1)*7
      if unoccupied?(next_pos)
        valid << next_pos
      else
        if piece_color(next_pos) == @@enemy_color
          valid << next_pos
        end
        break
      end
    end

    valid
  end

  # Castle: king cannot move into check, or through check
  def castle(index)
    valid = []
    dangerous_tiles = attack_vectors

    # King may never have moved
    if [5, 61].include?(index) && @@pieces[index][:moved] == false
      # Ensure empty space between a King and a Rook
      if unoccupied?(index - 1) && unoccupied?(index - 2) && unoccupied?(index - 3) && @@pieces[index - 4][:moved] == false
        # Ensure king does not move through check or into check
        if !dangerous_tiles.include?(index - 1) && !dangerous_tiles.include?(index - 2)
          # King's castle position
          valid << index - 2
        end
    
      elsif unoccupied?(index + 1) && unoccupied?(index + 2) && @@pieces[index + 3][:moved] == false
        if !dangerous_tiles.include?(index + 1) && !dangerous_tiles.include?(index + 2)
          valid << index + 2
        end
      end
    end
    
    valid
  end


  # Check if board tile currently has a piece
  def unoccupied?(index)
    if @@pieces[index][:color].nil?
      true
    else
      false
    end
  end


  # Return true if the piece has moved before
  def moved?(index)
    if @@pieces[index][:moved]
      true
    else
      false
    end
  end


  # Return piece color ("red" or "black") from index (1 - 64)
  def piece_color(index)
    @@pieces[index][:color]
  end


  # Method used when moving, to verify the piece at index (1 - 64) is not of type "king"
  def not_king(index)
    @@piece_locations[index][:type] == "king"
  end


  # Obtain chess board row number (1 + 8) from an index (1 - 64)
  def get_row_from_index(index)
    (index - 1)/8 + 1
  end


  # Obtain chess board column number (1 - 8) from an index (1 - 64)
  def get_col_from_index(index)
    if index % 8 == 0
      8
    else
      index % 8
    end
  end

end
