# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'terminal_chess/version'

Gem::Specification.new do |s|
  s.name        = 'terminal_chess'
  s.version     = TerminalChess::VERSION
  s.date        = '2015-03-03'
  s.summary     = "Chess game playable via the terminal"
  s.description = "Two player chess game through the terminal"
  s.authors     = ["Jason Willems"]
  s.email       = 'hello@jasonwillems.com'
  s.homepage    = 'https://github.com/atlas/Terminal-Chess'
  s.license     = 'MIT'

  s.files       = `git ls-files`.split("\n") 
  s.require_paths = ["lib"]

  s.add_runtime_dependency "colorize"
  s.add_development_dependency "bundler", "~> 1.7"
  s.add_development_dependency "rake", "~> 10.0"
end
