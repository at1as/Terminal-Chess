# frozen_string_literal: true

require 'faye/websocket'
require 'minitest/autorun'
require './lib/terminal_chess/server'

class TestServer < MiniTest::Test
  def setup_server(&_actions)
    sleep 2
    @server = Thread.new { TerminalChess::ChessServer.new }
    sleep 2
    yield
    teardown_server
  end

  def teardown_server
    Thread.kill(@server)
  end

  # TODO:
  # - The sleep intervals are to wait for data to be received
  #   These should be in some sort of wait_for loop that times out instead
  # - Add tests that move pieces and verify movements between clients
  # - Investigate better way to test websockets (library, etc)

  def test_connect
    setup_server do
      ws = Faye::WebSocket::Client.new("ws://127.0.0.1:4567")
      opened = false

      ws.on :open do
        opened = true
      end

      sleep 1
      assert_equal(true, opened)
    end
  end

  def test_first_player_connect_msg_received
    setup_server do
      ws = Faye::WebSocket::Client.new("ws://127.0.0.1:4567")
      messages = []
      expected = ["INFO: Player now connected to /",
                  "INFO: Awaiting second player..."]

      ws.on :message do |msg|
        messages << msg.data
      end

      sleep 2
      assert_equal(messages, expected)
    end
  end

  def test_two_player_connect_messages_received
    setup_server do
      ws1 = Faye::WebSocket::Client.new("ws://127.0.0.1:4567")
      ws2 = Faye::WebSocket::Client.new("ws://127.0.0.1:4567")

      messages_player1 = []
      messages_player2 = []

      expected_messages_player1 = [
        "INFO: Player now connected to /",
        "INFO: Awaiting second player...",
        "INFO: Connected to remote player",
        "SETUP: You are player 1"
      ]

      expected_messages_player2 = [
        "INFO: Player now connected to server at /",
        "INFO: Connected to remote player",
        "SETUP: You are player 2"
      ]

      ws1.on :message do |msg|
        messages_player1 << msg.data
      end
      ws2.on :message do |msg|
        messages_player2 << msg.data
      end

      sleep 2
      assert_equal(messages_player1, expected_messages_player1)
      assert_equal(messages_player2, expected_messages_player2)
    end
  end
end
