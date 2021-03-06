# frozen_string_literal: true

require 'minitest/autorun'
require 'helpers'
require "./lib/terminal_chess/board"
require "./lib/terminal_chess/messages"
require "./lib/terminal_chess/move"
require "./lib/terminal_chess/printer"
require "./lib/terminal_chess/version"

#  Note the tile Positions:
#
#     A,B,C,D,E,F,G,H
#    1   1-8
#    2   9-16
#    3   17-24
#    4   25-32
#    5   33-40
#    6   41-48
#    7   49-56
#    8   57-64

class TestBoard < MiniTest::Test
  include Helpers

  def setup
    @columns = %w[A B C D E F G H]
    @board = TerminalChess::Board.new
    @board.display_board
    @messages = TerminalChess::Messages
  end

  def valid_piece_movement(from)
    @board.valid_destinations(from)
  end

  def move_piece(from, to)
    @board.move(from, to)
  end

  def board_manifest
    @board.piece_manifest
  end

  def piece_quantity(piece)
    all_tiles = board_manifest
    count = 0
    all_tiles.each_value do |details|
      count += 1 if details.fetch(:type) == piece
    end

    count
  end

  def tile_empty(lowerbound, upperbound)
    all_tiles = board_manifest
    empty = true

    all_tiles.each do |num, details|
      if num >= lowerbound && num <= upperbound
        empty &&= details.fetch(:type).nil? # == "  "
      end
    end

    empty
  end

  def type_on_tile(index)
    all_tiles = board_manifest
    all_tiles.each do |num, details|
      return details.fetch(:type) if num == index
    end
  end

  def normalized_tile_name(indexes)
    # 13 -> A3 , 24 -> B4 , etc
    first, second = indexes.to_s.split("")
    Hash[("1".."8").zip("A".."H")][first] + second
  end

  ## Tests
  def version_exists
    assert_instance_of(String, TerminalChess::VERSION, "Version string not present")
  end

  def test_red_cannot_move_out_of_turn
    assert_equal(@messages.black_turn, @board.move("C7", "C5"))
  end

  def test_turn_does_not_change_after_invalid_move
    # Error moving black pawn (invalid)
    move_piece("H2", "H9")
    assert_equal(false, tile_empty(16, 16))

    # Success moving black pawn
    move_piece("H2", "H3")
    assert_equal(true, tile_empty(16, 16))
  end

  def test_unmoved_pawns_can_move_one_space
    assert_equal(piece_quantity(:pawn), 16)

    @columns.each do |c|
      move_piece("#{c}2", "#{c}3")
      move_piece("#{c}7", "#{c}6")
    end

    assert_equal(16, piece_quantity(:pawn), "There are no longer 16 pawns on the board")

    assert_equal(true,  tile_empty(9, 16),  "Pawns failed to move out of their starting positions")
    assert_equal(false, tile_empty(17, 24), "Pawns failed to move forward to positions one tile forward (tiles 17-24)")

    assert_equal(false, tile_empty(41, 48), "Pawns failed to move forward to positions one tile forward")
    assert_equal(true,  tile_empty(49, 56), "Pawns failed to move out of their starting positions (tiles 49-56)")
  end

  def test_unmoved_pawns_can_move_two_spaces
    assert_equal(piece_quantity(:pawn), 16)

    @columns.each do |c|
      move_piece("#{c}2", "#{c}4")
      move_piece("#{c}7", "#{c}5")
    end

    assert_equal(16, piece_quantity(:pawn), "There are no longer 16 pawns on the board")

    assert_equal(true,  tile_empty(9, 24),  "Pawns are still in their initial starting positions (tiles 9-24)")
    assert_equal(false, tile_empty(25, 32), "Pawns failed to move forward two positions")

    assert_equal(false, tile_empty(33, 40), "Pawns failed to move forward two positions")
    assert_equal(true,  tile_empty(41, 56), "Pawns are still in their initial starting position (tiles 41-56)")
  end

  def test_pawns_only_attack_diagonal
    move_piece("B2", "B4")
    move_piece("G7", "G5")
    move_piece("B4", "B5")
    move_piece("G5", "G4")
    move_piece("B5", "B6")
    move_piece("G4", "G3")

    assert_equal(%w[A7 C7], valid_piece_movement("B6"), "black pawn should only attack diagonally")
    assert_equal(%w[F2 H2], valid_piece_movement("G3"), "red pawn should only attack diagonally")
  end

  def test_bishops_can_move_over_pawns
    # Black
    assert_equal(%w[A3 C3], valid_piece_movement("B1"), "bishop should be able to jump over pawns")
    assert_equal(%w[F3 H3], valid_piece_movement("G1"), "bishop should be able to jump over pawns")

    # Red
    assert_equal(%w[A6 C6], valid_piece_movement("B8"), "bishop should be able to jump over pawns")
    assert_equal(%w[F6 H6], valid_piece_movement("G8"), "bishop should be able to jump over pawns")
  end

  def test_king_cannot_castle_through_check_to_right
    move_piece("G2", "G4")  # black pawn
    move_piece("A7", "A5")  # red pawn
    move_piece("F1", "H3")  # black bishop
    move_piece("A8", "A6")  # red rook
    move_piece("G1", "F3")  # black knight
    move_piece("A6", "G6")  # red rook
    move_piece("G4", "G5")  # black pawn
    move_piece("G6", "G5")  # red rook
    assert_equal(["F1"], valid_piece_movement("E1"), "King should only be allowed to move right one tile")

    move_piece("A2", "A3")  # black pawn
    move_piece("G5", "G2")  # red rook
    move_piece("A3", "A4")  # black pawn
    move_piece("G2", "F2")  # red rook
    assert_equal(@messages.black_in_check, move_piece("E1", "F1"), "King should not be allowed to move into check")
  end

  def test_king_cannot_castle_through_check_to_left
    move_piece("B1", "A3")  # black knight
    move_piece("A7", "A5")  # red pawn
    move_piece("D2", "D4")  # black pawn
    move_piece("A8", "A6")  # red rook
    move_piece("C1", "F4")  # black bishop
    move_piece("A6", "B6")  # red rook
    move_piece("D1", "D2")  # black queen
    move_piece("B6", "B2")  # black pawn
    assert_equal(%w[C1 D1], valid_piece_movement("E1"), "King should only be allowed to move left one or two tiles")

    move_piece("F4", "G5")  # black bishop
    move_piece("B2", "C2")  # red rook
    assert_equal(["D1"], valid_piece_movement("E1"), "King should only be allowed to move left one tile (or it's traversing check)")

    move_piece("G5", "H5")  # black bishop
    move_piece("C2", "D2")  # red rook
    assert_equal(["D1"], valid_piece_movement("E1"), "King should only be allowed to move left one tile (or it's traversing check)")
  end

  def test_king_can_castle_to_right
    move_piece("G2", "G4")  # black pawn
    move_piece("A7", "A5")  # red pawn
    move_piece("F1", "H3")  # black bishop
    move_piece("A8", "A6")  # red rook
    move_piece("G1", "F3")  # black knight
    move_piece("A5", "A4")  # red pawn
    assert_equal(%w[F1 G1], valid_piece_movement("E1"), "King should be allowed to move right one or two tiles")
  end

  def test_king_can_castle_to_left
    move_piece("B1", "A3")  # Error moving black pawn
    move_piece("A7", "A6")  # Error moving black pawn
    move_piece("D2", "D4")  # Error moving black pawn
    move_piece("B7", "B6")  # Error moving black pawn
    move_piece("C1", "F4")  # Error moving black pawn
    move_piece("C7", "C6")  # Error moving black pawn
    move_piece("D1", "D2")  # Error moving black pawn
    move_piece("D7", "D6")  # Error moving black pawn
    assert_equal(%w[C1 D1], valid_piece_movement("E1"), "King should be allowed to move left one or two tiles")
  end

  def test_king_cannot_castle_to_right_after_king_has_moved
    move_piece("G2", "G4")  # black pawn
    move_piece("A7", "A5")  # red pawn
    move_piece("F1", "H3")  # black bishop
    move_piece("A8", "A6")  # red rook
    move_piece("G1", "F3")  # black knight
    move_piece("A5", "A4")  # red pawn
    move_piece("E1", "F1")  # move king right one
    move_piece("H7", "H6")  # red pawn
    move_piece("F1", "E1")  # move king back to its original position
    assert_equal(["F1"], valid_piece_movement("E1"), "King should not be allowed to castle right after moving")
  end

  def test_king_cannot_castle_to_left_after_king_has_moved
    move_piece("B1", "A3")  #
    move_piece("A7", "A6")  #
    move_piece("D2", "D4")  #
    move_piece("B7", "B6")  #
    move_piece("C1", "F4")  #
    move_piece("C7", "C6")  #
    move_piece("D1", "D2")  #
    move_piece("D7", "D6")  #
    move_piece("E1", "D1")  # Move king left one position
    move_piece("H7", "H6")  # red pawn
    move_piece("D1", "E1")  # Move king back to original position
    assert_equal(["D1"], valid_piece_movement("E1"), "King should not be allowed to castle left after moving")
  end

  def test_king_cannot_castle_to_right_after_right_rook_has_moved
    move_piece("G2", "G4")  # black pawn
    move_piece("A7", "A5")  # red pawn
    move_piece("F1", "H3")  # black bishop
    move_piece("A8", "A6")  # red rook
    move_piece("G1", "F3")  # black knight
    move_piece("A5", "A4")  # red pawn
    move_piece("H1", "G1")  # move right rook left one position
    move_piece("H7", "H6")  # red pawn
    move_piece("G1", "H1")  # move right rook back to its original position
    assert_equal(["F1"], valid_piece_movement("E1"),
                 "King should not be allowed to castle right after right rook has moved")
  end

  def test_king_cannot_castle_to_left_after_left_rook_has_moved
    move_piece("B1", "A3")  #
    move_piece("A7", "A6")  #
    move_piece("D2", "D4")  #
    move_piece("B7", "B6")  #
    move_piece("C1", "F4")  #
    move_piece("C7", "C6")  #
    move_piece("D1", "D2")  #
    move_piece("D7", "D6")  #
    move_piece("A1", "B1")  # Move left rook right one position
    move_piece("H7", "H6")  # red pawn
    move_piece("B1", "A1")  # Move left rook back to original position
    assert_equal(["D1"], valid_piece_movement("E1"), "King should not be allowed to castle left after left rook has moved")
  end

  def test_king_can_castle_to_left_or_right_when_both_moves_valid
    move_piece("B1", "A3")  # black knight
    move_piece("A7", "A6")  # red pawn
    move_piece("D2", "D4")  # black pawn
    move_piece("B7", "B6")  # red pawn
    move_piece("C1", "F4")  # black bishop
    move_piece("C7", "C6")  # red pawn
    move_piece("D1", "D3")  # black queen  #=> castle left now valid
    move_piece("D7", "D6")  # red pawn
    move_piece("G1", "H3")  # black knight
    move_piece("E7", "E6")  # red pawn
    move_piece("G2", "G4")  # black pawn
    move_piece("F7", "F6")  # red pawn
    move_piece("F1", "G2")  # black bishop  #=> castle right now valid
    move_piece("G7", "G6")  # red pawn
    assert_equal(%w[C1 D1 D2 F1 G1],
                 valid_piece_movement("E1"),
                 "King should be allowed to castle left and right if both moves are valid")
  end

  def test_king_can_kill_check_attacker
    move_piece("A2", "A3")  # Error moving black pawn
    move_piece("A7", "A5")  # Error moving red pawn
    move_piece("A3", "A4")  # Error moving black pawn
    move_piece("A8", "A6")  # Error moving red rook
    move_piece("B2", "B3")  # Error moving black pawn
    move_piece("A6", "E6")  # Error moving red rook
    move_piece("B3", "B4")  # Error moving black pawn
    move_piece("E6", "E2")  # Error moving red rook
    assert_equal(@messages.black_in_check, move_piece("B4", "B5"))
    assert_equal(false, tile_empty(5, 5))

    move_piece("E1", "E2")  # Error moving black king
    assert_equal(true, tile_empty(5, 5))
  end

  def test_non_king_can_kill_check_attacker
    move_piece("A2", "A3")    # black pawn
    move_piece("A7", "A5")    # red pawn
    move_piece("A3", "A4")    # black pawn
    move_piece("A8", "A6")    # red rook
    move_piece("B2", "B3")    # black pawn
    move_piece("A6", "E6")    # red rook
    move_piece("B3", "B4")    # black pawn
    move_piece("E6", "E2")    # red rook
    assert_equal(@messages.black_in_check, move_piece("B4", "B5"))
    assert_equal(false, tile_empty(4, 4))

    move_piece("D1", "E2")
    assert_equal(true, tile_empty(4, 4))
  end

  def test_king_can_move_out_of_check
    move_piece("G2", "G3")  # black knight
    move_piece("A7", "A5")  # red pawn
    move_piece("F1", "H3")  # black pawn
    move_piece("A8", "A6")  # red rook
    move_piece("G3", "G4")  # black pawn
    move_piece("A6", "E6")  # red rook
    move_piece("G4", "G5")  # black pawn
    move_piece("E6", "E2")  # red rook
    assert_equal(@messages.black_in_check, move_piece("G5", "G6"))
    assert_equal(false, tile_empty(4, 4))

    move_piece("E1", "F1")
    assert_equal(true, tile_empty(5, 5))
  end

  def test_pawn_can_be_promoted
    move_piece("A2", "A4")
    move_piece("H7", "H6")
    move_piece("A4", "A5")
    move_piece("H6", "H5")
    move_piece("A5", "A6")
    move_piece("H5", "H4")
    move_piece("A6", "B7")
    move_piece("H4", "H3")
    $stdin = MyIO.new
    move_piece("B7", "C8")
    assert_equal(:queen, type_on_tile(59))
  end

  def test_pawn_cannot_be_promoted_out_of_turn
    move_piece("A2", "A4")
    move_piece("H7", "H6")
    move_piece("A4", "A5")
    move_piece("H6", "H5")
    move_piece("A5", "A6")
    move_piece("H5", "H4")
    move_piece("A6", "B7")
    $stdin = MyIO.new       # send 'Q' to stdin for pawn promotion
    assert_equal(@messages.red_turn, move_piece("B7", "C8"))
  end

  def test_pawn_cannot_be_promoted_while_check
    move_piece("A2", "A4")
    move_piece("H7", "H5")
    move_piece("A4", "A5")
    move_piece("H8", "H6")
    move_piece("A5", "A6")
    move_piece("H6", "E6")
    move_piece("A6", "B7")
    move_piece("E6", "E2")
    assert_equal(
      @messages.black_in_check,
      move_piece("B7", "C8"),
      "Should not be able to promote pawn while it's in check"
    )
    assert_equal(:pawn,   type_on_tile(50))
    assert_equal(:bishop, type_on_tile(59))
  end

  def test_checkmate_smothered_mate_kings_pawn
    move_piece("E2", "E4")
    move_piece("E7", "E5")
    move_piece("G1", "E2")
    move_piece("B8", "C6")
    move_piece("B1", "C3")
    move_piece("C6", "D4")
    move_piece("G2", "G3")
    assert_equal(@messages.red_winner, move_piece("D4", "F3"),
                 "Checkmate. Red should be victorious!")
  end

  def test_checkmate_fools_mate
    move_piece("F2", "F3")
    move_piece("E7", "E5")
    move_piece("G2", "G4")
    assert_equal(@messages.red_winner, move_piece("D8", "H4"), "Game should have ended as black is in checkmate")
  end

  def test_not_checkmate_when_piece_can_remove_checker
    # Black Rook should be able to take red bishop that has black king in check
    # hence piece is not in checkmate
    move_piece("F2", "F3")  # black pawn
    move_piece("E7", "E5")  # red pawn
    move_piece("G2", "G4")  # black pawn
    move_piece("A7", "A6")  # red pawn
    move_piece("H2", "H4")  # black pawn
    move_piece("A6", "A5")  # red pawn
    move_piece("H4", "H5")  # black pawn
    move_piece("D8", "H4")  # Check (from red queen)
    move_piece("H1", "H4")  # Take queen -> no longer in check
    assert_equal(:rook, type_on_tile(32)) # H5
  end

  def test_not_checkmate_when_piece_can_block_check_path
    move_piece("F2", "F3")  # black pawn
    move_piece("E7", "E5")  # red pawn
    move_piece("G2", "G4")  # black pawn
    move_piece("A7", "A6")  # red pawn
    move_piece("H2", "H4")  # black pawn
    move_piece("A6", "A5")  # red pawn
    move_piece("H4", "H5")  # black pawn
    move_piece("A5", "A4")  # red pawn
    move_piece("H1", "H2")  # black rook (will be able to block check path)
    move_piece("D8", "H4")  # red queen (black now in check)
    assert_equal(
      @messages.black_in_check, move_piece("A2", "A3"),
      "Should only be able to move out of check for next move"
    )
    move_piece("H2", "F2")  # black rook (check now blocked)
    move_piece("H4", "G3")  # red queen
    move_piece("B1", "A3")  # verify black is no longer in check and can move any piece
  end

  def test_invalid_pawn_moves_not_accepted
    piece_to_move    = (9..16).to_a.sample # piece from black pawn row
    piece_type       = type_on_tile(piece_to_move)
    invalid_location = ((1..8).to_a + (33..64).to_a).sample # rows outside of scope
    location_type    = type_on_tile(invalid_location)

    from = normalized_tile_name(TerminalChess::Board.new.get_rowcol_from_index(piece_to_move))
    to   = normalized_tile_name(TerminalChess::Board.new.get_rowcol_from_index(invalid_location))

    move_piece(from, to)

    assert_equal(location_type, type_on_tile(invalid_location))
    assert_equal(piece_type, type_on_tile(piece_to_move))
  end

  def test_non_knights_can_not_move_over_populated_pawn_row
    piece_to_move    = ((1..8).to_a - [2, 7]).sample # first row without knights
    piece_type       = type_on_tile(piece_to_move)
    invalid_location = (17..64).to_a.sample # rows outside of scope
    location_type    = type_on_tile(invalid_location)

    from = normalized_tile_name(TerminalChess::Board.new.get_rowcol_from_index(piece_to_move))
    to   = normalized_tile_name(TerminalChess::Board.new.get_rowcol_from_index(invalid_location))

    move_piece(from, to)

    assert_equal(location_type, type_on_tile(invalid_location))
    assert_equal(piece_type, type_on_tile(piece_to_move))
  end
end
