#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH << './lib'

require 'terminal_chess/local_chess_client'
require 'terminal_chess/network_chess_client'
require 'terminal_chess/server'

if ENV["SERVER"]
  TerminalChess::ChessServer.new
elsif ENV["NGROK"]
  TerminalChess::NetworkChessClient.new(ENV["NGROK"])
else
  TerminalChess::LocalChessClient.new
end
