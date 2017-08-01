Terminal-Chess
==============

A lightweight two-player chess game for the Terminal, written in Ruby

![Screenshot](http://at1as.github.io/github_repo_assets/terminal_chess-2.png)

 
### Usage

The easiest way to use terminal_chess is to install it via the [Rubygem](https://rubygems.org/gems/terminal_chess). This is likely to be several commits/weeks behind, but generally more stable.

Otherwise, clone this repo directly and run:

```bash
# Download Repo
$ git clone git@github.com:at1as/Terminal-Chess.git
$ chmod +x lib/terminal_chess.rb

# Install Dependencies. Only dependency is the colorize gem
$ bundle install

# Run program in terminal
$ ruby lib/terminal_chess.rb
```

Testing:

```bash
$ bundle exec rake test --trace
```

### Limitations
* Built and tested on macOS 10.11 with Ruby 2.4.0
* Neither player can currently be automated

### TODO:
* Automate one of two players
* Multiplayer support
* Switch written Chess pieces to unicode characters
