Terminal-Chess
==============

A two-player chess game for the Terminal, written in Ruby (output below is colorized when run in the terminal)
<pre>
					>> Welcome to Terminal Chess v0.1.0

    _A__  _B__  _C__  _D__  _E__  _F__  _G__  _H__
   |    ||    ||    ||    ||    ||    ||    ||    |
 1 |    || KN || BI || QU || KI || BI || KN || RO | 1
   |____||____||____||____||____||____||____||____|
   |    ||    ||    ||    ||    ||    ||    ||    |
 2 |    || PA || PA || PA || PA || PA || PA || PA | 2
   |____||____||____||____||____||____||____||____|
   |    ||    ||    ||    ||    ||    ||    ||    |
 3 |    ||    ||    ||    || RO ||    ||    ||    | 3
   |____||____||____||____||____||____||____||____|
   |    ||    ||    ||    ||    ||    ||    ||    |
 4 | PA ||    ||    ||    ||    ||    ||    ||    | 4
   |____||____||____||____||____||____||____||____|
   |    ||    ||    ||    ||    ||    ||    ||    |
 5 | PA ||    ||    ||    ||    ||    ||    ||    | 5
   |____||____||____||____||____||____||____||____|
   |    ||    ||    ||    ||    ||    ||    ||    |
 6 |    ||    ||    ||    ||    ||    ||    ||    | 6
   |____||____||____||____||____||____||____||____|
   |    ||    ||    ||    ||    ||    ||    ||    |
 7 |    || PA || PA || PA || PA || PA || PA || PA | 7
   |____||____||____||____||____||____||____||____|
   |    ||    ||    ||    ||    ||    ||    ||    |
 8 | RO || KN || BI || QU || KI || BI || KN || RO | 8
   |____||____||____||____||____||____||____||____|
     A     B     C     D     E     F     G     H

Piece to Move: B8
Valid destinations: C6, A6
Location: c6

</pre>

![Screenshot](http://at1as.github.io/github_repo_assets/terminal_chess.jpg)

 
### Usage
The easiest way to use terminal_chess is to install it via the [Rubygem](https://rubygems.org/gems/terminal_chess). This is likely to be a few commits behind, but generally more stable.

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
* For now, checkmate will need to be verified manually
* TODO: Code cleanup. Printer module is painful to read.
* Niether player can be automated
