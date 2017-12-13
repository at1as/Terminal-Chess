# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'terminal_chess/version'

Gem::Specification.new do |s|
  s.name        = 'terminal_chess'
  s.version     = TerminalChess::VERSION
  s.date        = '2017-12-12'
  s.summary     = "Chess game playable via the terminal"
  s.description = "Two player chess game through the terminal"
  s.authors     = ["Jason Willems"]
  s.email       = 'hello@jasonwillems.com'
  s.homepage    = 'https://github.com/at1as/Terminal-Chess'
  s.license     = 'MIT'

  s.files       = `git ls-files`.split("\n") 
  s.require_paths = ["lib"]
  s.executables << 'terminal_chess'

  s.add_runtime_dependency "colorize"
  s.add_runtime_dependency "em-websocket"
  s.add_runtime_dependency "eventmachine"
  s.add_runtime_dependency "faye-websocket"
  s.add_development_dependency "bundler", "~> 1.7"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "minitest"
end
