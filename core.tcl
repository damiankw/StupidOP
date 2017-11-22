putlog " > Loading core.tcl ..."
proc seen_top_text {text user_list {limit 10}} {
  array set users $user_list
  set top ""
  set cnt 1
  foreach item $text {
    if {[expr $cnt % 2]} {
      set top "$top $users($item):\[[lindex $text $cnt]\]"
    }
    if {$cnt >= [expr $limit * 2]} {
      break
    }
    
    incr cnt
  }
  
  return [string trim $top]
}

proc stupid_autosave {} {
  # save
  array_save seen seen.dat
  array_save game game.dat
  
  if {![check_timer stupid_autosave]} {
    timer 10 stupid_autosave
  }
}

proc check_timer {name} {
  foreach timer [timers] {
    if {[lindex $timer 1] == $name} {
      return 1
    }
  }
  
  return 0
}

proc check_utimer {name} {
  foreach timer [utimers] {
    if {[lindex $timer 1] == $name} {
      return 1
    }
  }
  
  return 0
}

proc seen_to_text {item {full 0}} {
  switch [lindex $item 2] {
    "TEXT" {
      set msg "writing in [lindex $item 3], [duration [expr ([clock seconds] - [lindex $item 0])]] ago"
      
      if {$full} {
        set msg "$msg ([lrange $item 4 end])"
      }
      
      return $msg
    }
    "JOIN" {
      return "joining [lindex $item 3], [duration [expr ([clock seconds] - [lindex $item 0])]] ago"
    }
    "PART" {
      set msg "parting [lindex $item 3], [duration [expr ([clock seconds] - [lindex $item 0])]] ago"
      
      if {$full} {
        set msg "$msg ([lrange $item 4 end])"
      }
      
      return $msg
    }
    "QUIT" {
      set msg "quitting IRC, [duration [expr ([clock seconds] - [lindex $item 0])]] ago"
      
      if {$full} {
        set msg "$msg ([lrange $item 4 end])"
      }
      
      return $msg
    }
    "KICK" {
      return "kicking [lindex $item 4] from [lindex $item 3], [duration [expr ([clock seconds] - [lindex $item 0])]] ago"
    }
    "KICKED" {
      return "kicked from [lindex $item 3] by [lindex $item 4], [duration [expr ([clock seconds] - [lindex $item 0])]] ago"
    }
    "NICK" {
      return "changing nickname to [lindex $item 4], [duration [expr ([clock seconds] - [lindex $item 0])]] ago"
    }
    "TOPIC" {
      set msg "changing the topic in [lindex $item 3], [duration [expr ([clock seconds] - [lindex $item 0])]] ago"
      
      if {$full} {
        set msg "$msg ([lrange $item 4 end])
      }
      
      return $msg
    }
  }
}

proc seen_add {nuhost cmd text} {
  global seen
  set seen([clock seconds],[lindex [split [string tolower $nuhost] "!"] 0],[string tolower [lindex $text 0]],[string tolower $cmd]) "$nuhost $cmd $text"
}

proc seen_search {nick {chan "*"} {cmd "*"}} {
  global seen
  set search [lsort -decreasing [array names seen *,[string tolower $nick],[string tolower $chan],[string tolower $cmd]]]
  
  return $search
}

proc seen_get {item} {
  global seen
  return "[lindex [split $item ","] 0] $seen($item)"
}

proc game_check {} {
  global game
  # go through the current robberies and see if any have expired
  foreach item [array names game *,steal] {
    if {$game($item) == ""} {
      array unset game $item
    } elseif {$game($item) == 0} {
      continue
    } elseif {[expr [lindex $game($item) 0] + 300] < [clock seconds]} {
      msg [lindex $game($item) 1] "[lindex $game($item) 2] has stolen \$[lindex $game($item) 4].00 from [lindex $game($item) 3]!!!!!!"
      game_player_decr [lindex $game($item) 3] wallet [lindex $game($item) 4]
      game_player_incr [lindex $game($item) 3] lost [lindex $game($item) 4]
      game_player_incr [lindex $game($item) 2] wallet [lindex $game($item) 4]
      game_player_incr [lindex $game($item) 2] stolen [lindex $game($item) 4]
      array unset game [replace [replace $item \[ \\\[] \] \\\]]
    }
  }
  
  foreach item [array names game *,welfare] {
    if {$game($item) == 0} {
      continue
    } elseif {[lindex $game($item) 1] < [clock seconds]} {
      msg [lindex $game($item) 3] "10,7 ! 7,10 ! 1,8 W 1,3 E 1,9 L 1,10 F 1,9 A 1,3 R 1,8 E 7,10 ! 10,7 !  ::: [lindex $game($item) 4]'s welfare payment has come through. \$[lindex $game($item) 2] has gone into their wallet!!"
      game_player_incr [lindex $game($item) 4] wallet [lindex $game($item) 2]
      array unset game [replace [replace $item \[ \\\[] \] \\\]]
    }
  }
  
  foreach item [array names game *,jail] {
    if {$game($item) == 0} {
      continue
    } elseif {[lindex $game($item) 0] < [clock seconds]} {
      msg [lindex $game($item) 1] "12,0 ! 0,12 ! 12,0 P 0,12 O 12,0 L 0,12 I 12,0 C 0,12 E 12,0 ! 0,12 !  ::: [lindex $game($item) 2] has been released from jail!!!"
      array unset game [replace [replace $item \[ \\\[] \] \\\]]
    }
  }
  
  if {![check_utimer game_check]} {
    utimer 10 game_check
  }
}

proc game_player_win {nick amount} {
  game_player_incr $nick won $amount
  game_player_incr $nick wallet $amount
  game_incr total.winners
  game_incr total.jackpot $amount
  game_set last.winner $nick
  game_set last.jackpot $amount
}

# check to see if the user has the variables required for no errors, create them if they don't
proc game_player_check {user} { # updated
  global game
  if {![info exists game([string tolower $user],spent)]} {
    set game([string tolower $user],spent) 0
  }

  if {![info exists game([string tolower $user],won)]} {
    set game([string tolower $user],won) 0
  }

  if {![info exists game([string tolower $user],bank)]} {
    set game([string tolower $user],bank) 0
  }
  
  if {![info exists game([string tolower $user],wallet)]} {
    set game([string tolower $user],wallet) 50
  }
  
  if {![info exists game([string tolower $user],steal)]} {
    set game([string tolower $user],steal) 0
  }
  
  if {![info exists game([string tolower $user],stolen)]} {
    set game([string tolower $user],stolen) 0
  }
  
  if {![info exists game([string tolower $user],lost)]} {
    set game([string tolower $user],lost) 0
  }
  
  if {![info exists game([string tolower $user],nick)]} {
    set game([string tolower $user],nick) $user
  }
}

# check if the player has enough funds to do the command
proc game_funds_check {user price} {
  if {[game_player_get $user wallet] >= $price} {
    # the player has enough funds in their wallet
    return 1
  } elseif {[game_player_get $user bank] >= $price} {
    # the player has funds in the bank, but needs to withdraw
    return -1
  } else {
    # the player doesn't have the funds at all
    return 0
  }
}

# get player items (wallet, bank, etc), easier than using $game()
proc game_player_get {user item} { # updated
  global game
  
  if {![info exists game([string tolower $user],[string tolower $item])]} {
    return 0
  } else {
    return $game([string tolower $user],[string tolower $item])
  }
}

proc game_player_set {user item value} {
  global game
  
  set game([string tolower $user],[string tolower $item]) $value
}

# increase the players item
proc game_player_incr {user item {value 1}} {
  global game
  
  incr game([string tolower $user],[string tolower $item]) $value
}

# decrease the players item
proc game_player_decr {user item {value 1}} {
  global game
  
  incr game([string tolower $user],$item) -$value
}

# delete a player
proc game_player_del {nick} {
  global game
  array unset game [string tolower $nick],*
}

proc game_incr {item {value 1}} {
  global game
  
  incr game([string tolower $item]) $value
}

# decrease the players item
proc game_decr {item {value 1}} {
  global game
  
  incr game([string tolower $item]) $value
}

# set a variable
proc game_set {item value} {
  global game
  
  set game([string tolower $item]) $value
}

proc game_get {item} {
  global game
  
  if {![info exists game([string tolower $item])]} {
    return ""
  }
  
  return $game([string tolower $item])
}

proc game_flood_check {nick} {
  # only do one command every 4 seconds
  if {[expr [clock seconds] - [game_player_get $nick flood]] <= 5} {
    return 1
  } else {
    game_player_set $nick flood [clock seconds]
    return 0
  }
}

proc game_rank_get {} {
  # get the wallet+bank
  global game
  foreach item [array names game *,wallet] {
    set total([lindex [split $item ,] 0]) [expr [game_player_get [lindex [split $item ,] 0] wallet] + [game_player_get [lindex [split $item ,] 0] bank]]
  }
  
  set rank [array_sort [array get total]]
  
  return $rank
}

proc array_sort {items} {
  set sort [lsort -decreasing -integer -stride 2 -index 1 $items]
  
  set cnt 1
  set list ""
  foreach item $sort {
    if {[expr $cnt % 2]} {
      set list "$list $item"
    }
    
    incr cnt 1
  }
  
  return [string trim $list]
}

proc seen_top_text {text user_list {limit 10}} {
  array set users $user_list
  set top ""
  set cnt 1
  foreach item $text {
    if {[expr $cnt % 2]} {
      set top "$top $users($item):\[[lindex $text $cnt]\]"
    }
    if {$cnt >= [expr $limit * 2]} {
      break
    }
    
    incr cnt
  }
  
  return [string trim $top]
}


# displays all of the active theft/rob attempts
proc game_steal_get {{nick *}} {
 global game
 set list ""
 foreach item [array names game *,steal] {
   if {($game($item) != 0) && ([string match [string tolower $nick] [string tolower [lindex $game($item) 2]]])} {
     set list "$list {$game($item)}"
   }
 }
 
 return [string trim $list]
}

# load the seen database if it exists
if {![array exists seen] && [file exists "seen.dat"]} {
  putlog ".. loading SEEN internal database (seen.dat)."
  source seen.dat
}

# load the game database if it exists
if {![array exists game] && [file exists "game.dat"]} {
  putlog ".. loading game internal database (game.dat)."
  source game.dat
}


if {![info exists game(jackpot)]} {
  set game(jackpot) [rand 200]
  set game(total.winners) 0
  set game(total.jackpot) 0
  set game(last.winner) "n/a"
  set game(last.jackpot) "0"
}

proc joke_read {file} {
  set A [expr [rand [expr [lines stupidop/files/joke.txt] / 2]] * 2]
  set Q [expr $A - 1]
  
  return "{[string trim [lrange [readline stupidop/files/joke.txt $Q] 1 end]]} {[string trim [lrange [readline stupidop/files/joke.txt $A] 1 end]]}"
}

proc game_bj_play_dealer {nick chan} {
  set msg "1,4 ! 4,1 ! 1,4 B 4,1 L 1,4 A 4,1 C 1,4 K 4,1 J 1,4 A 4,1 C 1,4 K 4,1 ! 1,4 !  ::: $nick, dealer had [lindex [game_player_get $nick bj.dealer] 0] ([game_bj_get_total [game_player_get $nick bj.dealer]]) ::: "
  
  while {[game_bj_get_total [game_player_get $nick bj.dealer]] < 16} {
#    if {[game_bj_get_total [game_player_get $nick bj.dealer]] > [game_bj_get_total [game_player_get $nick bj.cards]]} {
#      break
#    }
    
    set card [game_bj_get_card $nick]
    game_player_set $nick bj.dealer "[game_player_get $nick bj.dealer] $card"
  }
  
  
  if {([game_bj_get_total [game_player_get $nick bj.dealer]] == 21) && ([game_bj_get_total [game_player_get $nick bj.cards]] == 21)} {
    msg $chan "$msg dealer drew [replace [lrange [game_player_get $nick bj.dealer] 1 end] " " ", "] ([game_bj_get_total [game_player_get $nick bj.dealer]]) ::: 1,4DRAW!!!"
    game_player_win $nick [game_player_get $nick bj.bet]
    game_player_set $nick bj.cards 0
    
  } elseif {[game_bj_get_total [game_player_get $nick bj.dealer]] == 21} {
    msg $chan "$msg dealer drew [replace [lrange [game_player_get $nick bj.dealer] 1 end] " " ", "] ([game_bj_get_total [game_player_get $nick bj.dealer]]) ::: 1,4$nick LOSES!!!"
    game_player_set $nick bj.cards 0
    
  } elseif {[game_bj_get_total [game_player_get $nick bj.dealer]] > 21} {
    msg $chan "$msg dealer drew [replace [lrange [game_player_get $nick bj.dealer] 1 end] " " ", "] ([game_bj_get_total [game_player_get $nick bj.dealer]]) ::: dealer went bust :::  1,4$nick WINS \$[expr [game_player_get $nick bj.bet] * 2].00!!!!"
    game_player_win $nick [expr [game_player_get $nick bj.bet] * 2]
    game_player_set $nick bj.cards 0
    
  } elseif {[game_bj_get_total [game_player_get $nick bj.dealer]] == [game_bj_get_total [game_player_get $nick bj.cards]]} {
    msg $chan "$msg dealer drew [replace [lrange [game_player_get $nick bj.dealer] 1 end] " " ", "] ([game_bj_get_total [game_player_get $nick bj.dealer]]) ::: 1,4DRAW!!"
    game_player_win $nick [expr [game_player_get $nick bj.bet] * 2]
    game_player_set $nick bj.cards 0
    
  } elseif {[game_bj_get_total [game_player_get $nick bj.dealer]] > [game_bj_get_total [game_player_get $nick bj.cards]]} {
    msg $chan "$msg dealer drew [replace [lrange [game_player_get $nick bj.dealer] 1 end] " " ", "] ([game_bj_get_total [game_player_get $nick bj.dealer]]) ::: 1,4$nick LOSES!!"
    game_player_set $nick bj.cards 0
    
  } else {
    msg $chan "$msg dealer drew [replace [lrange [game_player_get $nick bj.dealer] 1 end] " " ", "] ([game_bj_get_total [game_player_get $nick bj.dealer]]) ::: 1,4$nick WINS \$[expr [game_player_get $nick bj.bet] * 2].00!!"
    game_player_win $nick [expr [game_player_get $nick bj.bet] * 2]
    game_player_set $nick bj.cards 0
  }
}

proc game_bj_get_card {nick} {
  set index [rand [llength [game_player_get $nick bj.deck]]]
  set card [lindex [game_player_get $nick bj.deck] $index]
  game_player_set $nick bj.deck [lremove [game_player_get $nick bj.deck] $index]
  return $card
}

proc game_bj_get_total {cards} {
  set total 0
  set held ""
  foreach card $cards {
    set c [lindex [split $card "("] 0]
    if {[string tolower $c] == "ace"} {
      set held "$held $card"
    } else {
      incr total [game_card_to_num $c]
    }
  }
  
  foreach card $held {
    if {$total <= 10} {
      incr total 11
    } else {
      incr total 1
    }
  }
  
  return $total
}

proc game_card_to_num {card} {
  if {[string tolower $card] == "ace"} {
    return 11
  } elseif {[string tolower $card] == "jack"} {
    return 10
  } elseif {[string tolower $card] == "queen"} {
    return 10
  } elseif {[string tolower $card] == "king"} {
    return 10
  } else {
    return $card
  }
}

proc game_num_to_card {num} {
  if {$num == 1} {
    return "Ace"
  } elseif {$num == 11} {
    return "Jack"
  } elseif {$num == 12} {
    return "Queen"
  } elseif {$num == 13} {
    return "King"
  } else {
    return $num
  }
}

proc seen_get_host {nick} {
  global seen
  set hosts ""
  foreach item [array names seen *,[string tolower $nick],*,*] {
    set host [lindex [split [lindex [data_tidy $seen($item)] 0] !] 1]
    if {($host != "") && ([lsearch -exact [string tolower $hosts] [string tolower $host]] == -1)} {
      set hosts "$hosts $host"
    }
  }
  
  return [data_tidy [string trim $hosts] 1]
}

game_check

stupid_autosave














