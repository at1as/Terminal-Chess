class Messages
  
  @red_turn   = "It is red's turn. Please move a red piece."
  @black_turn = "It is black's turn. Please move a black piece."
  
  @red_in_check   = "Please move red king out of check to continue"
  @black_in_check = "Please move black king out of check to continue"
  @red_winner     = "Checkmate! Red Player Wins!"
  @black_winner   = "Checkmate! Black Player Wins!"
  @checkmate      = "Checkmate! Game Over."

  @invalid = "Invalid Selection"

  class << self
    attr_reader(
      :checkmate,
      :red_turn,
      :black_turn,
      :red_in_check,
      :black_in_check,
      :invalid
    )
  end
end
