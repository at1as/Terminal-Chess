Terminal-Chess
==============

A chess game written for terminal in Ruby (output below is colorized when run in the terminal)
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
Valid destinations: ["C6", "A6"]
Location: c6

</pre>

### Requirements
Requires the colorize Ruby gem
```bash
$ sudo gem install colorize
```

### Installation
```bash
$ git clone git@github.com:at1as/Terminal-Chess.git
```

### Usage
```bash
$ ./chess.rb
```

### Limitations
* Checkmate currently requires the user to attempt to move their checkmated king, before being notified they are in checkmate
* Castling is still a feature in progress
* There is currently no AI for Player 2
