require 'em-websocket'

class ChessServer
  def initialize
    start
  end

  def start
    EventMachine.run do

      clients = []
      game_ongoing = false
      p [:start, "Waiting for clients to connect..."]

      EM::WebSocket.start(:host => '0.0.0.0', :port => '4567') do |ws|

        ws.onopen do |handshake|
          p [:open]
          if @game_ongoing 
            ws.send "Game already in progress"
            ws.close
          else
            puts "Now connected to client"
          end
          
          if clients.length == 0
            puts "Waiting for second client"
            clients << ws
            ws.send "INFO: Player now connected to #{handshake.path}"
            ws.send "INFO: Awaiting second player..."
          
          elsif clients.length == 1
            clients << ws
            puts "Starting Game..."
            ws.send "INFO: Player now connected to server at #{handshake.path}"

            clients.each_with_index do |client, idx|
              client.send "INFO: Connected to remote player"
              client.send "SETUP: You are player #{idx+1}"
            end
          end
        end

        ws.onmessage do |msg|
          p [:message, msg]
          opposing_player = (clients - [ws]).first

          # Send opposing player the new move
          opposing_player.send msg
        end

        ws.onerror do |err|
          p [:error, err]
        end

        ws.onclose do
          clients.each do |client|
            client.send "INFO: Player has left the game"
            client.close unless client.state == :closed
          end

          p [:close, "Client disconnected. Disconnecting all players"]

          # End session for all clients
          clients = []
          game_ongoing = false
        end

      end
    end
  end

end
