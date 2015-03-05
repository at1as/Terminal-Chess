#!/usr/bin/env ruby

module PRINTER

  VERSION ||= "0.1.0"
  COLS ||= ['A','B','C','D','E','F','G','H']
  @@n = 0
  @@print_count = 1


  # Prints the board to terminal, based on layout defined by piece_locations
  def printer
    
    # Clear and reset counters
    @@print_count = 1
    system "clear" or system "cls"

    # Header (title & column labels)
    print "\n\t>> Welcome to Terminal Chess v#{VERSION}\n\n\s\s\s"
    COLS.each { |c| print " _#{c}__ " }
    puts "\n"

    # Print Cells (use printer block and pass cell styling in loop below)
    (1..8).each do |row|
      yield "|    |"
      yield "| XX |", "#{row}"
      yield "|____|"
    end

    # Footer (print column labels)
    print "\s\s\s"
    COLS.each { |c| print "  #{c}   " }
    puts ""
  end


  def print_board(piece_locations)
    printer { |i, j|

      # Print preceeding row index (1...8) if applicable
      if j then print " #{j} " else print "   " end
      if @@n < 3
        # Print cell (4 characters wide, 3 characters tall)
        4.times do
          color = piece_locations[@@print_count]["color"] || "black"
          next_color = piece_locations[@@print_count+1]["color"] || "black"
          print "#{i}".gsub("XX", piece_locations[@@print_count]["type"][0..1].upcase).colorize(:"#{color}").on_light_white
          print "#{i}".gsub("XX", piece_locations[@@print_count+1]["type"][0..1].upcase).colorize(:"#{next_color}").on_light_black
          if "#{i}".include? "XX"
            # Incremenet print_count, unless last cell is being printed, to avoid an out of range error
            @@print_count += 2 unless @@print_count == 63
          end
        end
      else
        # Print cell starting with alternative color (4 characters wide, 3 characters tall)
        4.times do
          color = piece_locations[@@print_count]["color"] || "black"
          next_color = piece_locations[@@print_count+1]["color"] || "black"
          print "#{i}".gsub("XX", piece_locations[@@print_count]["type"][0..1].upcase).colorize(:"#{color}").on_light_black
          print "#{i}".gsub("XX", piece_locations[@@print_count+1]["type"][0..1].upcase).colorize(:"#{next_color}").on_light_white
          if "#{i}".include? "XX"
            @@print_count += 2 unless @@print_count == 63
          end
        end
      end

      # Print succeeding row index (1...8) if applicable
      if (@@n == 1 || @@n == 4) && j then print " #{j}" end

      # Incriment row index. Reset once n reaches 6 (i.e., two complete cell rows have been printed - the pattern to repeat)
      @@n += 1
      if @@n == 6 then @@n = 0 end
      puts ""
    }
  end

end
