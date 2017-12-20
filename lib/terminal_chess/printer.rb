#!/usr/bin/env ruby
# frozen_string_literal: true

module TerminalChess
  module Printer
    # TODO : Replace text pieces with unicode symbols
    PIECE_TO_UNICODE_MAPPING ||= {
      "pa": "♙",
      "ro": "♖",
      "bi": "♗",
      "kn": "♘",
      "ki": "♔",
      "qu": "♕"
    }.freeze
    COLS ||= ('A'..'H')

    @@subrow = 0        # Reference to current row within a cell
    @@cell_number = 1   # Reference to the current cell

    def print_header
      # Print chess board Header (Title and then Column Labels A to H)
      print "\n\t>> Welcome to Terminal Chess v#{TerminalChess::VERSION}\n\n"
      print "\s\s\s" # cell padding

      COLS.each { |c| print "  #{c}   " }
      puts
    end

    def print_footer
      # Print chess board footer (Column Labels A to H)
      print "\s\s\s" # cell padding

      COLS.each { |c| print "  #{c}   " }
      puts
    end

    def print_start_of_row(row_num)
      # Pad the start of each row with spacing or the row numbers 1..8
      if row_num
        print " #{row_num} "
      else
        print " " * 3
      end
    end

    def print_end_of_row(row_num)
      # Print row number 1...8 at end of each row
      print " #{row_num}" if (@@subrow == 1 || @@subrow == 4) && row_num
    end

    def clear_all
      # Reset counters and clear terminal
      @@cell_number = 1
      system("clear") or system("cls")
    end

    def printer
      # Prints the board to terminal, based on layout defined by piece_locations

      clear_all
      print_header

      # Print first cell of each row, with row number
      (1..8).each do |row|
        yield "      "
        yield "  XX  ", row.to_s
        yield "      "
      end

      print_footer
    end

    def substitute_pieces(text, index, color, background_color, piece_locations)
      piece = piece_to_string(piece_locations[index][:type])

      piece = piece.upcase unless piece == "pa"
      piece = piece.colorize(color)

      if background_color == :white
        text.gsub("XX", piece).on_light_white
      else
        text.gsub("XX", piece).on_light_black
      end
    end

    def piece_to_string(piece_name)
      # Print pieces as two characters
      #   "pawn" -> "pa" , "bishop" -> "BI" , "king" -> "KI" , ...
      #   print nil as "  " so it takes up a two character width on the printed board
      piece_name.nil? ? "  " : piece_name[0..1]
    end

    def print_board(piece_locations)
      printer do |tile_text, row_num|
        print_start_of_row(row_num)

        4.times do
          # Print cell and next neighboring cell,
          # then loop until 4 pairs of 2 cells have been printed, completing row
          color      = piece_locations[@@cell_number][:color]     || :black
          next_color = piece_locations[@@cell_number + 1][:color] || :black

          # Print two rows at a time as every two rows repeat
          #  alternating tile colors
          #    ________________________
          #   |   ###   ###   ###   ###| -> subrow 0
          #   |   ###   ###   ###   ###| -> subrow 1
          #   |   ###   ###   ###   ###| -> subrow 2
          #   |###   ###   ###   ###   | -> subrow 3
          #   |###   ###   ###   ###   | -> subrow 4
          #   |###   ###   ###   ###   | -> subrow 5
          #

          if @@subrow < 3
            print substitute_pieces(
              tile_text, @@cell_number, color, :white, piece_locations
            )
            print substitute_pieces(
              tile_text, @@cell_number + 1, next_color, :black, piece_locations
            )
          else
            print substitute_pieces(
              tile_text, @@cell_number, color, :black, piece_locations
            )
            print substitute_pieces(
              tile_text, @@cell_number + 1, next_color, :white, piece_locations
            )
          end

          next unless tile_text.include? "XX"
          
          # Incremenet cell_number unless last cell is being printed
          # to avoid an out of range error
          @@cell_number += 2 unless @@cell_number == 63
        end

        print_end_of_row(row_num)

        # Incriment row index.
        # Reset once n reaches 6 (i.e., two complete cell rows have been printed - the pattern to repeat)
        @@subrow += 1
        @@subrow  = 0 if @@subrow == 6
        puts
      end
    end
  end
end
