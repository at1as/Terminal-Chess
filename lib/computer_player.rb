require_relative './move'

class ComputerPlayer

  def initialize(color)
    self.color = color
  end

  def points(piece)
    {
      :pawn   => 1,
      :rook   => 5,
      :knight => 3,
      :bishop => 3,
      :queen  => 9,
    }[piece]
  end

  def next_move(current_board)
    # TODO: return best next move
  end

end
