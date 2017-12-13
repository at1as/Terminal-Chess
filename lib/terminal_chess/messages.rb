class Messages

  @red_turn   = "It is red's turn. Please move a red piece."
  @black_turn = "It is black's turn. Please move a black piece."

  @red_in_check   = "Please move red king out of check to continue"
  @black_in_check = "Please move black king out of check to continue"
  @red_winner     = "Checkmate! Red Player Wins!"
  @black_winner   = "Checkmate! Black Player Wins!"
  @invalid        = "Invalid Selection"

  @piece_moved    = "Piece moved"

  class << self
    attr_reader(
      :red_turn,
      :black_turn,
      :red_in_check,
      :black_in_check,
      :red_winner,
      :black_winner,
      :checkmate,
      :invalid,
      :piece_moved
    )
  end
end
