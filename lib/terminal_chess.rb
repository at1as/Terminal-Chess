#!/usr/bin/env ruby

$LOAD_PATH << __FILE__ # '.'

require_relative 'local_chess_client'
require_relative 'network_chess_client'

if ENV["NGROK"]
  NetworkChessClient.new(ENV["NGROK"])
else
  LocalChessClient.new
end

