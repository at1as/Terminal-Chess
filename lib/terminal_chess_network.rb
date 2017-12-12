
$LOAD_PATH << __FILE__ # '.'

require 'eventmachine'
require 'faye/websocket'

require_relative "terminal_chess/version"
require_relative "printer.rb"
require_relative "move.rb"
require_relative "board.rb"


class ChessClient
  def initialize
    @board = Board.new
    @turn_by_turn_playback = []
    @game_started = false
    @player_num   = nil
    @player_turn  = false
    @messages     = []

    start_client
  end

  private

  def start_client
    Thread.new {
      EM.run do
        ws = Faye::WebSocket::Client.new("ws://8cf6d5ce.ngrok.io")

        ws.on :open do
          p [:open]
        end

        ws.on :message do |msg|
          p [:message, msg.data]

          if msg.data.match "SETUP: You are player [1|2]"
            @player_num   = msg.data.split(' ').last.strip.to_i
            @player_turn  = true if @player_num == 1
            @game_started = true
          end

          if msg.data.match "MOVE: [a-zA-Z][0-9], [a-zA-Z][0-9]"
            from, to = msg.data.match("MOVE: \([a-zA-Z][0-9]\), \([a-zA-Z][0-9]\)").captures

            @board.move(from, to)
            @player_turn = true
          end
        end

        ws.on :close do |e|
          p [:closed, e.code, e.reason]
        end

        EventMachine::PeriodicTimer.new(1) do
          next unless @player_turn && @game_started
          
          piece_moved = local_move
          if piece_moved
            @player_turn = false
            ws.send "MOVE: #{@turn_by_turn_playback.last[0]}, #{@turn_by_turn_playback.last[1]}"
          end
        end
      end
    }.join 
  end
  
  
  def local_move
    if @board.checkmate
      puts "\nTurn by Turn Playback : #{@turn_by_turn_playback}\n"
      exit
    end

    print "\nPiece to Move [#{@board.player_turn.capitalize}]: "
    from = gets.chomp.upcase

    begin
      print "Valid destinations: #{@board.valid_destinations(from).join(", ")}"

      print "\nLocation: "
      to = gets.chomp.upcase
      @board.move(from, to)

    rescue Exception => e
      puts "Invalid selection #{e if !ENV["DEV"].nil?}"
    else
      @turn_by_turn_playback << [from, to]
      true
    end
  end

end

ChessClient.new

