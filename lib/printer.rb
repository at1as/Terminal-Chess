#!/usr/bin/env ruby

module Printer

  # TODO : Replace text pieces with unicode symbols
  PIECE_TO_UNICODE_MAPPING ||= {
    "pa": "♙",
    "ro": "♖",
    "bi": "♗",
    "kn": "♘",
    "ki": "♔",
    "qu": "♕"
  }

  COLS ||= ('A'..'H')
  @@subrow = 0        # Reference to current row within a cell
  @@print_count = 1   # Reference to the current cell


  def print_header
    # Print chess board Header (Title and then Column Labels A to H)
    print "\n\t>> Welcome to Terminal Chess v#{TerminalChess::VERSION}\n\n\s\s\s"
    COLS.each { |c| print "  #{c}   " }
    puts
  end
  
  def print_footer
    # Print chess board footer (Column Labels A to H)
    print "\s\s\s"
    COLS.each { |c| print "  #{c}   " }
    puts
  end
  
  def print_start_of_row(row_num)
    # Begin each board row by printing row index (1..8) in the vertical center of each cell
    # Otherwise pad with spaces for correct alignment
    if row_num
      print " #{row_num} "
    else
      print " " * 3
    end
  end

  def print_end_of_row(row_num)
    # Print succeeding row index (1...8) if applicable
    if (@@subrow == 1 || @@subrow == 4) && row_num
      print " #{row_num}"
    end
  end

  def clear_all
    # Reset counters and clear terminal
    @@print_count = 1
    system "clear" or system "cls"
  end


  def printer
    # Prints the board to terminal, based on layout defined by piece_locations
    
    clear_all
    print_header

    # Print first cell of each row, with row number
    (1..8).each do |row|
      yield "      "
      yield "  XX  ", "#{row}"
      yield "      "
    end
    
    print_footer
  end

  def substitute_pieces(text, index, color, background_color, piece_locations)
    piece = piece_locations[index]["type"][0..1]
    piece.upcase! unless piece == "pa"
    piece = piece.colorize(:color => color.to_sym)

    if background_color == "white"
      return text.gsub("XX", piece).on_light_white
    else 
      return text.gsub("XX", piece).on_light_black
    end
  end

  def print_board(piece_locations)
    printer do |i, row_num|

      print_start_of_row(row_num)
      
      # Print row of cells line by line
      4.times do
        # Print cell and next cell
        color = piece_locations[@@print_count]["color"] || "black"
        next_color = piece_locations[@@print_count + 1]["color"] || "black"
        
        if @@subrow < 3
          print substitute_pieces(i, @@print_count, color, "white", piece_locations)
          print substitute_pieces(i, @@print_count + 1, next_color, "black", piece_locations)
        else
          print substitute_pieces(i, @@print_count, color, "black", piece_locations)
          print substitute_pieces(i, @@print_count + 1, next_color, "white", piece_locations)
        end

        if "#{i}".include? "XX"
          # Incremenet print_count, unless last cell is being printed, to avoid an out of range error
          @@print_count += 2 unless @@print_count == 63
        end
      end

      print_end_of_row(row_num)

      # Incriment row index. Reset once n reaches 6 (i.e., two complete cell rows have been printed - the pattern to repeat)
      @@subrow += 1
      @@subrow = 0 if @@subrow == 6
      puts
    end
  end

end
