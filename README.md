Terminal-Chess
==============

A lightweight two-player chess game for the Terminal, written in Ruby

![Screenshot](http://at1as.github.io/github_repo_assets/terminal_chess-2.png)

 
### Installing

The easiest way to use terminal_chess is to install it via the [Rubygem](https://rubygems.org/gems/terminal_chess). Note that the Gem is *way* out of date when compared to the repo

Otherwise, clone this repo directly and run:

```bash
# Download Repo
$ git clone git@github.com:at1as/Terminal-Chess.git
$ chmod +x lib/terminal_chess.rb

# Install Dependencies. Only dependency is the colorize gem
$ bundle install
```

### Running

#### Local Gameplay

In this mode, the game will launch in Terminal and allow the player to make moves for both sides of the board

```
# Run program in terminal

$ ruby lib/terminal_chess.rb
```

#### Multiplayer

Terminal Chess can connect to an opponent using websockets over ngrok. The requires first starting the server:

```
# The webserver must be running either on one of the players machines
# Or somewhere else. This will need to be running before either client can connect
$ lib/server.rb 

# The host running the server will need to tunnel the connection through ngrok
# on the free plan the URL will change every time ngrok is launched
# therefor the `9cf13f35` component will need to be passed to the clients in order
# to connect
$ ngrok http 4567
 => http://9cf13f35.ngrok.io -> localhost:4567
```

And then the client can connect via the NGROK environment variable. if this environment variable is set, the client will attempt to start a session over the network. If the connection  

```
# Replace the NGROK enviroment variable with whatever URL the ngrok server returned
$ NGROK=9cf13f5 ruby lib/terminal_chess.rb

# => [:message, "INFO: Awaiting second player..."]
```

And once the second client connects, game on!

```
$ NGROK=9cf13f5 ruby lib/terminal_chess.rb

# => [:message, "INFO: Connected to remote player"]
# => [:message, "SETUP: You are player 2"]
# => [:message, "INFO: Starting game!"]
```

Any subsequent clients that attempt to connect while the game is in session will have their connections dropped

### Testing:

```bash
$ bundle exec rake test --trace
```

### Notes
* Built and tested on macOS 10.11 with Ruby 2.4.0
* Neither player can currently be automated

### TODO:
* Update Gem to reflect the last two years' repo changes...
* Automate one of two players (note: tried this. Not easy to make it competent)
* Switch written Chess pieces to unicode characters (note: tried this. Didn't look great)
