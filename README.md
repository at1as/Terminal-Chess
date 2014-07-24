Terminal-Chess
==============

A chess game written for terminal in Ruby (output below is colorized when run in the terminal)
<pre>
		>> Welcome to Terminal Chess v0.1.0

    _A__  _B__  _C__  _D__  _E__  _F__  _G__  _H__ 
   |    ||    ||    ||    ||    ||    ||    ||    |
 1 | RO || KN || BI || QU || KI || BI || KN || RO | 1
   |____||____||____||____||____||____||____||____|
   |    ||    ||    ||    ||    ||    ||    ||    |
 2 |    || PA || PA || PA || PA || PA || PA || PA | 2
   |____||____||____||____||____||____||____||____|
   |    ||    ||    ||    ||    ||    ||    ||    |
 3 |    ||    ||    ||    ||    ||    ||    ||    | 3
   |____||____||____||____||____||____||____||____|
   |    ||    ||    ||    ||    ||    ||    ||    |
 4 | PA ||    ||    ||    ||    ||    ||    ||    | 4
   |____||____||____||____||____||____||____||____|
   |    ||    ||    ||    ||    ||    ||    ||    |
 5 |    ||    ||    ||    ||    ||    ||    ||    | 5
   |____||____||____||____||____||____||____||____|
   |    ||    ||    ||    ||    ||    ||    ||    |
 6 |    ||    ||    ||    ||    ||    ||    ||    | 6
   |____||____||____||____||____||____||____||____|
   |    ||    ||    ||    ||    ||    ||    ||    |
 7 | PA || PA || PA || PA || PA || PA || PA || PA | 7
   |____||____||____||____||____||____||____||____|
   |    ||    ||    ||    ||    ||    ||    ||    |
 8 | RO || KN || BI || QU || KI || BI || KN || RO | 8
   |____||____||____||____||____||____||____||____|
     A     B     C     D     E     F     G     H   

2.1.2 :004 > a.move "A2", "A4"
</pre>

### Requirements
Requires the colorize Ruby gem
```bash
$sudo gem install colorize
```

### Installation
```bash
$ git clone git@github.com:at1as/Terminal-Chess.git
```

### Usage
```bash
$ irb
$ load 'Board.rb'; a = Board.new; a.setup_board; a.board_refresh
$ move("A2", "A4")
```

### Limitations
This is an untested work in progress. Check currently requires the King to be moved. i.e., another piece cannot be moved to get the King out of check. This will be fixed shortly.
