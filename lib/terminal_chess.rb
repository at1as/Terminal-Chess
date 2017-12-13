#!/usr/bin/env ruby

$LOAD_PATH << __FILE__ # '.'

require_relative 'local_chess_client'
require_relative 'network_chess_client'
require_relative 'server'

if ENV["SERVER"]
  ChessServer.new
elsif ENV["NGROK"]
  NetworkChessClient.new(ENV["NGROK"])
else
  LocalChessClient.new
end

