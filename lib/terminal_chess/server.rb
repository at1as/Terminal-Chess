require 'em-websocket'

module TerminalChess
  # Websocket server to pass messages (moves) between two connected chess players
  class ChessServer
    def initialize
      start
    end

    def start
      EventMachine.run do
        clients = []
        game_ongoing = false
        p [:start, "Waiting for clients to connect..."]

        EM::WebSocket.start(host: '0.0.0.0', port: '4567') do |ws|
          ws.onopen do |handshake|
            clients = handle_open(clients, handshake, ws, game_ongoing)
          end

          ws.onmessage do |msg|
            handle_msg(msg, clients, ws)
          end

          ws.onerror do
            handle_error
            clients = handle_close(clients)
            game_ongoing = false
          end

          ws.onclose do
            clients = handle_close(clients)
            game_ongoing = false
          end
        end
      end
    end

    def handle_open(clients, handshake, ws, game_ongoing)
      p [:open]
      if game_ongoing
        ws.send "Game already in progress"
        ws.close
      else
        puts "Now connected to client"
      end

      if clients.empty?
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
          client.send "SETUP: You are player #{idx + 1}"
        end
      end

      clients
    end

    def handle_msg(msg, clients, ws)
      p [:message, msg]
      opposing_player = (clients - [ws]).first

      # Send opposing player the new move
      opposing_player.send msg
    end

    def handle_error
      p [:error]
    end

    def handle_close(clients)
      clients.each do |client|
        client.send "INFO: Player has left the game"
        client.close unless client.state == :closed
      end

      p [:close, "Client disconnected. Disconnecting all players"]

      []
    end
  end
end
