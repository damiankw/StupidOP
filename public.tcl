bind pub - $sb(cmd)help pub:help
bind pub - $sb(cmd)rtfm pub:help
bind pub - $sb(cmd)man pub:help
bind pub - $sb(cmd)commands pub:help
bind pub - $sb(cmd)spin pub:spin
bind pub - $sb(cmd)roll pub:roll
bind pub - $sb(cmd)throw pub:throw
bind pub - $sb(cmd)cash pub:cash
bind pub - $sb(cmd)bank pub:bank
bind pub - $sb(cmd)rob pub:rob
bind pub - $sb(cmd)jackpot pub:jackpot
bind pub - $sb(cmd)withdraw pub:withdraw
bind pub - $sb(cmd)profile pub:profile
bind pub - $sb(cmd)police pub:police
bind pub - $sb(cmd)rank pub:rank
bind pub n $sb(cmd)give pub:give
bind pub n $sb(cmd)merge pub:merge
bind pubm - * slot:pubm

array set slot_items "bell {1,10 [align "BELL" 10 " " C] } cherry {1,5 [align "CHERRY" 10 " " C] } plum {1,6 [align "PLUM" 10 " " C] } weed {1,9 [align "WEED" 10 " " C] } strawberry {0,4 [align "STRAWBERRY " 10 " " C] } coal {0,1 [align "COAL" 10 " " C] } blueberry {1,11 [align "BLUEBERRY" 10 " " C] } orange {1,7 [align "ORANGE" 10 " " C] } apple {4,3 [align "APPLE" 10 " " C] } banana {1,8 [align "BANANA" 10 " " C] }"

proc pub:help {nick uhost handle chan text} {
  slot_player_check $nick

  set cmd [string trim [string tolower [lindex $text 0]] .]
  if {[lindex $text 0] == ""} {
    notice $nick "|[align " Game Commands " 78 "-" C]|"
    notice $nick "| .spin     : Play the pokies.          | .roll     : Play the dice.            |"
    notice $nick "| .throw    : Play the coins.           | .cash     : Check player cash.        |"
    notice $nick "| .rob      : Steal player cash.        | .jackpot  : Check slot jackpot.       |"
    notice $nick "| .bank     : Put money in the bank.    | .withdraw : Put money in your wallet. |"
    notice $nick "| .rank     : Check player rank.        |                                       |"
    notice $nick "|[align " Utility Commands " 78 "-" C]|"
    notice $nick "| .seen     : Check user whereabouts.   | .top      : Check user statistics.    |"
    notice $nick "| .random   : Say user text.            |                                       |"
    notice $nick "|-------------------------------------------------------------------------------|"
    notice $nick "For more information on any command, visit https://stupid.nictitate.net/ or use: .help <command>"
  } elseif {$cmd == "spin"} {
    notice $nick "Usage: .spin"
    notice $nick "     - Play the pokies for \$1.00 and gives you the change to win the JACKPOT!"
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?spin"
  } elseif {$cmd == "roll"} {
    notice $nick "Usage: .roll"
    notice $nick "     - Play the dice for \$1.00 and win small amounts of money."
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?roll"
  } elseif {$cmd == "throw"} {
    notice $nick "Usage: .throw"
    notice $nick "     - Play the coins for \$1.00 and win small amounts of money."
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?throw"
  } elseif {$cmd == "cash"} {
    notice $nick "Usage: .cash \[<nick>\]"
    notice $nick "     - Shows the current cash for the player (or yourself if no player is specified)"
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?cash"
  } elseif {$cmd == "rob"} {
    notice $nick "Usage: .rob <nick>"
    notice $nick "     - Attempts to rob the player from their wallet. They have five minutes to say anything in the channel to stop you."
    notice $nick "     - If the player stops you, you will drop cash, even if you have none! BEWARE!"
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?rob"
  } elseif {$cmd == "jackpot"} {
    notice $nick "Usage: .jackpot"
    notice $nick "     - Shows you the statistics from pokies."
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?jackpot"
  } elseif {$cmd == "bank"} {
    notice $nick "Usage: .bank \[<amount>\]"
    notice $nick "     - Banks the amount so no one can steal it from you without a group effort vault break. If no amount is specified, it will bank all of your cash."
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?bank"
  } elseif {$cmd == "withdraw"} {
    notice $nick "Usage: withdraw \[<amount>\]"
    notice $nick "     - Withdraws the amount and puts it in your wallet for use. If no amount is specified, \$100 will be withdrawn."
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?withdraw"
  } elseif {$cmd == "rank"} {
    notice $nick "Usage: .rank \[<nick>] [-<top x|list>\]"
    notice $nick "     - -top <n> : Lists the top N players."
    notice $nick "     - -list    : Lists the players around the selected player."
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?rank"
  } elseif {$cmd == "seen"} {
    notice $nick "Usage: .seen <nick> \[-cmd <command>|-limit <num>|-chan <chan>\]"
    notice $nick "     - Attempt to find when the user was last active on the network, the switches will specify search parameters. Defaults to all commands and all channels with a limit of 1."
    notice $nick "     % -cmd <command> : Search only the command queried, valid commands are TEXT|JOIN|PART|QUIT|NICK|KICK|KICKED"
    notice $nick "     % -limit <num>   : Return this number of search results, maximum is 10."
    notice $nick "     % -chan <chan>   : Search only in the channel queried."
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?seen"
  } elseif {$cmd == "top"} {
    notice $nick "Usage: .top \[-today|-yesterday|-week|-month|-alltime\] \[-lines|-words|-stats|-all\] \[-global|-chan <chan>\]"
    notice $nick "     - Display the top chatters through the history. Default is the top lines for all time on the current channel."
    notice $nick "     % -<date field> : Display statistics for the period queried."
    notice $nick "     % -<type>       : Displays the statistics queried."
    notice $nick "     % -global       : Displays statistics for all channels."
    notice $nick "     % -chan <chan>  : Displays statistics for the channel queried."
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?top"
  } elseif {$cmd == "random"} {
    notice $nick "Usage: .random \[<nick>\]"
    notice $nick "     - Displays a random line from nick. If no nick is specified, it chooses a random line from everyone."
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?random"
  } else {
    notice $nick "Invalid request: That is not a valid option."
  }
}

proc pub:police {nick uhost handle chan text} {
  slot_player_check $nick
  
  # .police <nick> - calls the police on the nick
  if {[lindex $text 0] == ""} {
    notice $nick "Who are you calling the police on?"
  } elseif {[slot_steal_get [lindex $text 0]] == ""} {
    msg $chan "$nick tried to call the cops on [lindex $text 0] but they haven't done anything! $nick gets locked up."
  } else {
    foreach theft [slot_steal_get] {
      if {[string tolower [lindex $theft 2]] == [string tolower [lindex $text 0]]} {
        set jail [rand 20]
        msg $chan "$nick called the police on [lindex $text 0], he's FUCKED!"
        msg $chan "! ! P O L I C E ! ! ::: Caught [lindex $text 0], $jail minutes in jail!"
        slot_player_set [lindex $text 0] jail [expr [clock seconds] + ($jail * 60)]
      }
    }
  }
}

proc pub:rank {nick uhost handle chan text} {
  slot_player_check $nick
  
  # .rank [<nick>] [-<top x|list>]
  array set search [checkswitch $text "top 1" "top 0 list 0"]

  if {$search(top) > 0} {
    set user *
  } elseif {[lindex $search(text) 0] == ""} {
    set user $nick
  } else {
    set user [lindex $search(text) 0]
  }
  
  set rank_list [slot_rank_get]
  
  set user_rank [lsearch -exact $rank_list $user]
  
  if {($user_rank == -1) && ($user != "*")} {
    notice $nick "$user was not found in the database."
  } elseif {$user != "*" && (!$search(list))} {
    notice $nick "Found [lindex $search(text) 0] ranked #[expr $user_rank + 1] with \$[expr [slot_player_get [lindex $search(text) 0] wallet] + [slot_player_get [lindex $search(text) 0] bank]].00."
  } else {
    if {$search(top) > 20} {
      set start 0
      set end 19
    } elseif {$search(top) > 0} {
      set start 0
      set end [expr $search(top) - 1]
    } elseif {$user_rank < 5} {
      set start 0
      set end 9
    } elseif {$user_rank > [expr [llength $rank_list] - 6]} {
      set start [expr [llength $rank_list] - 10]
      set end [expr [llength $rank_list] - 1]
    } elseif {$user_rank >= 5} {
      set start [expr $user_rank - 4]
      set end [expr $user_rank + 5]
    }

    set cnt $start
    set total 0

    notice $nick "*** Listing Ranks \[Match: $user\] of [llength $rank_list] entries ***"
    notice $nick "      NickName                     Wallet            Bank           Total"
    while {$cnt <= $end} {
      set luser [lindex $rank_list $cnt]
      set ltotal [expr [slot_player_get $luser wallet] + [slot_player_get $luser bank]]
      if {[string tolower $luser] == [string tolower $user]} {
        set highlight "9,1"
      } else {
        set highlight ""
      }

      notice $nick "$highlight[align [expr $cnt + 1] 5] [align $luser 19] [align \$[slot_player_get $luser wallet].00 15 " " R ] [align \$[slot_player_get $luser bank].00 15 " " R ] [align \$$ltotal.00 15 " " R ]"

      incr cnt
      incr total
    }
    notice $nick "*** End of List ***"
  }
}

proc pub:give {nick uhost handle chan text} {
  # .give <player> <amount> - gives the player a boost in their wallet
  if {[lindex $text 1] == ""} {
    set cash 100
  } else {
    set cash [string trim [lindex [split [lindex $text 1] .] 0] "\$"]
  }

  if {[lindex $text 0] == ""} {
    notice $nick "You need to tell me who to give cash to."
  } elseif {$cash <= 0} {
    notice $nick "You have to at least give \$1.00."
  } elseif {![isnum [string trim $cash "\$"]]} {
    notice $nick "You need to provide a number/currency."
  } else {
    slot_player_incr [lindex $text 0] wallet $cash
    msg $chan "% $nick (admin) gave [lindex $text 0] \$$cash.00."
  }
}

proc pub:merge {nick uhost handle chan text} {
  # .merge <nick1> <nick1> - merge nick1 into nick2
  if {[lindex $text 1] == ""} {
    notice $nick "ass, give me two nicknames"
  } else {
    slot_player_incr [lindex $text 1] won [slot_player_get [lindex $text 0] won]
    slot_player_incr [lindex $text 1] lost [slot_player_get [lindex $text 0] lost]
    slot_player_incr [lindex $text 1] spent [slot_player_get [lindex $text 0] spent]
    slot_player_incr [lindex $text 1] stolen [slot_player_get [lindex $text 0] stolen]
    slot_player_incr [lindex $text 1] wallet [slot_player_get [lindex $text 0] wallet]
    slot_player_incr [lindex $text 1] bank [slot_player_get [lindex $text 0] bank]
    slot_player_del [lindex $text 0]
  }
}

proc pub:roll {nick uhost handle chan text} {
  slot_player_check $nick
  
  if {[slot_flood_check $nick]} {
    notice $nick "You can't play again for another [expr [slot_player_get $nick flood] + 5 - [clock seconds]] seconds."
  } elseif {[slot_funds_check $nick 1] == -1} {
    notice $nick "You don't have enough funds in your wallet for this, please withdraw from the bank!"
  } elseif {[slot_funds_check $nick 1] == 0} {
    notice $nick "You don't have enough funds in your wallet or in the bank for this, go raise some cash!"
  } else {
    slot_player_incr $nick spent 1
    slot_player_decr $nick wallet 1
    
    set item(1) [rand 7]
    while {$item(1) == 0} {
      set item(1) [rand 7]
    }
    
    set item(2) [rand 7]
    while {$item(2) == 0} {
      set item(2) [rand 7]
    }
    
    set win 0
    set slang ""
    set msg "0,4 ! 4,0 ! 0,4 D 4,0 I 0,4 C 4,0 E 0,4 ! 4,0 !  ::: \[ 0,4 $item(1)  | 0,4 $item(2)  \] ::: "
    
    if {($item(1) == $item(2)) && ($item(1) == 1)} {
      set win 2
      set slang "SNAKE EYES"
    } elseif {($item(1) == $item(2)) && ($item(1) == 2)} {
      set win 5
      set slang "HARD FOUR"
    } elseif {($item(1) == $item(2)) && ($item(1) == 3)} {
      set win 10
      set slang "HARD SIX"
    } elseif {($item(1) == $item(2)) && ($item(1) == 4)} {
      set win 10
      set slang "HARD EIGHT"
    } elseif {($item(1) == $item(2)) && ($item(1) == 5)} {
      set win 50
      set slang "HARD TEN"
    } elseif {($item(1) == $item(2)) && ($item(1) == 6)} {
      set win 100
      set slang "BOXCARS"
    }
    
    if {$win == 0} {
      set msg "$msg $nick lost!"
    } else {
      set msg "$msg $nick just won \$$win.00 ::: $slang!!!"
      slot_incr total.winners
      slot_incr total.jackpot $win
      slot_player_incr $nick won $win
      slot_player_incr $nick wallet $win
      slot_set last.winner $nick
      slot_set last.jackpot $win
    }
    
    msg $chan $msg
  }
}

proc pub:throw {nick uhost handle chan text} {
  slot_player_check $nick
  
  if {[slot_flood_check $nick]} {
    notice $nick "You can't play again for another [expr [slot_player_get $nick flood] + 5 - [clock seconds]] seconds."
  } elseif {[slot_funds_check $nick 1] == -1} {
    notice $nick "You don't have enough funds in your wallet for this, please withdraw from the bank!"
  } elseif {[slot_funds_check $nick 1] == 0} {
    notice $nick "You don't have enough funds in your wallet or in the bank for this, go raise some cash!"
  } else {
    slot_player_incr $nick spent 1
    slot_player_decr $nick wallet 1
    
    set item(1) [rand 2]
    set item(2) [rand 2]
    
    if {$item(1)} {
      set item(1.1) "8,9 HEADS "
    } else {
      set item(1.1) "9,8 TAILS "
    }
    
    if {$item(2)} {
      set item(2.2) "8,9 HEADS "
    } else {
      set item(2.2) "9,8 TAILS "
    }
    
    set win 0
    set slang ""
    set msg "8,9 ! 9,8 ! 8,9 T 9,8 W 8,9 O 9,8 - 8,9 U 9,8 P 8,9 ! 9,8 !  ::: \[ $item(1.1) | $item(2.2) \] ::: "
    
    if {($item(1) == $item(2)) && ($item(1) == 1)} {
      set win 20
      msg $chan "$msg $nick won \$20.00!! HEADS!!!"
      slot_incr total.winners
      slot_incr total.jackpot $win
      slot_set last.winner $nick
      slot_set last.jackpot $win
    } elseif {($item(1) == $item(2)) && ($item(1) == 0)} {
      set win 0
      msg $chan "$msg TAILS!! $nick lost!!"
    } else {
      set win 1
      msg $chan "$msg ODDS!! $nick plays again!"
      set slang "ODDS"
    }
    
    if {$win == 0} {
      set msg "$msg $nick lost! $slang"
    } else {
      slot_player_incr $nick won $win
      slot_player_incr $nick wallet $win
    }
  }
}

proc pub:spin {nick uhost handle chan text} {
  global slot_items
  
  # configure the player defaults if they don't already exist
  slot_player_check $nick
  
  # check if the user has money to play
  if {[slot_flood_check $nick]} {
    notice $nick "You can't play again for another [expr [slot_player_get $nick flood] + 5 - [clock seconds]] seconds."
  } elseif {[slot_funds_check $nick 1] == -1} {
    notice $nick "You don't have enough funds in your wallet for this, please withdraw from the bank!"
  } elseif {[slot_funds_check $nick 1] == 0} {
    notice $nick "You don't have enough funds in your wallet or in the bank for this, go raise some cash!"
  } else {
    # spin up the slots
    set item(1) $slot_items([lindex [array names slot_items] [rand [llength [array names slot_items]]]])
    set item(2) $slot_items([lindex [array names slot_items] [rand [llength [array names slot_items]]]])
    set item(3) $slot_items([lindex [array names slot_items] [rand [llength [array names slot_items]]]])

    # set the start message
    set msg "1,10 ! 1,5 ! 1,6 P 1,9 O 0,4 K 0,1 I 1,11 E 1,7 S 4,3 ! 1,8 !  ::: \[\$[slot_get jackpot].00\] ::: \[ $item(1) | $item(2) | $item(3) \] :::"

    # it costs $1
    slot_player_incr $nick spent 1
    slot_player_decr $nick wallet 1

    if {($item(1) == $item(2)) && ($item(2) == $item(3))} {
      # we have a winner!
      set msg "$msg 0 1,8 J 1,4 A 1,9 C 1,7 K 1,13 P 1,11 O 1,5 T    !!! $nick just won \$[slot_get jackpot].00!!!"
      slot_incr total.winners
      slot_incr total.jackpot [slot_get jackpot]
      slot_player_incr $nick won [slot_get jackpot]
      slot_player_incr $nick wallet [slot_get jackpot]
      slot_set last.winner $nick
      slot_set last.jackpot [slot_get jackpot]
      slot_set jackpot [rand 200]
    } else {
      set msg "$msg $nick lost!"
      slot_incr jackpot [rand 5]
    }

    msg $chan $msg

    set bonus [rand 1000]
    if {$bonus < 100} {
      # add in a bonus if we get a random number less than 100
      msg $chan "1,9 ! 9,1 ! 1,9 B 9,1 O 1,9 N 9,1 U 1,9 S 9,1 ! 1,9 !    :::   AN EXTRA \$$bonus.00 HAS BEEN ADDED TO THE JACKPOT!!!"
      slot_incr jackpot $bonus
    }
  }
}

proc pub:jackpot {nick uhost handle chan text} {
  notice $nick "Current Jackpot:\[\$[slot_get jackpot].00\] Last Jackpot:\[\$[slot_get last.jackpot].00\] Last Winner:\[[slot_get last.winner]\] Total Winners:\[[slot_get total.winners]\] Total Jackpots:\[[slot_get total.jackpot]\]"
}

proc pub:cash {nick uhost handle chan text} {
  slot_player_check $nick
  
  global slot
  if {[lindex $text 0] == ""} {
    set user $nick
  } else {
    set user [lindex $text 0]
  }
  
  notice $nick "Amount Won:\[\$[slot_player_get $user won].00\] Amount Spent:\[\$[slot_player_get $user spent].00\] Wallet:\[\$[slot_player_get $user wallet].00\] Bank:\[\$[slot_player_get $user bank].00\]"
}

proc pub:profile {nick uhost handle chan text} {
  slot_player_check $nick
  
  global slot
  if {[lindex $text 0] == ""} {
    set user $nick
  } else {
    set user [lindex $text 0]
  }
  
  notice $nick "|[align " Player Information for $user " 62 "-" C]|"
  notice $nick "| In-Wallet : \$[align [slot_player_get $user wallet].00 15] | In-Bank   : \$[align [slot_player_get $user bank].00 15] |"
  notice $nick "| Spent     : \$[align [slot_player_get $user spent].00 15] | Won       : \$[align [slot_player_get $user won].00 15] |"
  notice $nick "| Lost      : \$[align [slot_player_get $user lost].00 15] | Stolen    : \$[align [slot_player_get $user stolen].00 15] |"
  if {[slot_player_get $user jail] != 0} {
  notice $nick "| [align "[slot_player_get $user nick] is in jail for [expr ([slot_player_get $user jail] - [clock seconds]) / 60] minutes." 59] |"
  }
  notice $nick "|[align "" 61 "-"]|"
}

proc pub:withdraw {nick uhost handle chan text} {
  slot_player_check $nick
  
  # .withdraw [<amount>]
  if {[lindex $text 0] == ""} {
    set withdraw 100
    
    if {$withdraw > [slot_player_get $nick bank]} {
      set withdraw [slot_player_get $nick bank]
    }
  } else {
    set withdraw [string trim [lindex [split $text .] 0] "\$"]
  }
  
  if {[slot_player_get $nick bank] == 0} {
    notice $nick "You currently have nothing in your bank, you can't withdraw."
  } elseif {$withdraw <= 0} {
    notice $nick "You have to at least withdraw \$1.00"
  } elseif {![isnum $withdraw]} {
    notice $nick "You need to provide a number/currency."
  } elseif {$withdraw > [slot_player_get $nick bank]} {
    notice $nick "You currently have \$[slot_player_get $nick bank].00 in your bank, you can't withdraw \$$withdraw.00."
  } else {
    slot_player_incr $nick wallet $withdraw
    slot_player_decr $nick bank $withdraw
    msg $chan "0,1 ! 1,0 ! 0,1 B 1,0 A 0,1 N 1,0 K 0,1 ! 1,0 !  $nick has withdrawn \$$withdraw.00, leaving \$[slot_player_get $nick bank].00 in their bank."
  }
}

proc pub:bank {nick uhost handle chan text} {
  global slot
  slot_player_check $nick
  
  if {[lindex $text 0] == ""} {
    set bank [slot_player_get $nick wallet]
  } else {
    set bank [string trim [lindex [split $text .] 0] "\$"]
  }
  
  if {[slot_player_get $nick wallet] == 0} {
    notice $nick "You currently have nothing in your wallet, you can't bank."
  } elseif {[slot_player_get $nick wallet] < 0} {
    notice $nick "You currently owe money, you can't bank."
  } elseif {$bank <= 0} {
    notice $nick "You have to at least bank \$1.00."
  } elseif {![isnum [string trim $bank "\$"]]} {
    notice $nick "You need to provide a number/currency."
  } elseif {[slot_player_get $nick wallet] < $bank} {
    notice $nick "You currently have \$[slot_player_get $nick wallet].00 in your wallet, you can't bank \$$bank.00."
  } else {
    slot_player_incr $nick bank $bank
    slot_player_decr $nick wallet $bank
    msg $chan "0,1 ! 1,0 ! 0,1 B 1,0 A 0,1 N 1,0 K 0,1 ! 1,0 !  $nick has banked \$$bank.00, leaving \$[slot_player_get $nick wallet].00 in their wallet."
  }
}

proc pub:rob {nick uhost handle chan text} {
  global slot
  slot_player_check $nick
  
  if {[lindex $text 0] == ""} {
    notice $nick "Who are you trying to steal money from?"
  } else {
    if {[string tolower [lindex $text 0]] == [string tolower $nick]} {
      notice $nick "You can't steal from yourself, idiot."
    } elseif {![onchan [lindex $text 0] $chan]} {
      notice $nick "[lindex $text 0] isn't currently in the channel, how are you meant to steal money from them?!"
    } elseif {([slot_player_get [lindex $text 0] wallet] <= 10) && ([slot_player_get [lindex $text 0] bank] > 10)} {
      notice $nick "[lindex $text 0] is smart, they have banked all of their money!"
    } elseif {[slot_player_get [lindex $text 0] wallet] <= 10} {
      notice $nick "[lindex $text 0] is unlucky, they don't have money to steal!"
    } elseif {[slot_player_get [lindex $text 0] steal] != 0} {
      notice $nick "You or someone else already trying to steal money from [lindex $text 0]!"
    } else {
      set amount [rand [expr [slot_player_get [lindex $text 0] wallet] / 2]]
      slot_player_set [lindex $text 0] steal "[clock seconds] $chan $nick [lindex $text 0] $amount"
      msg $chan "1,7 ! 7,1 ! 1,7 W 7,1 A 1,7 R 7,1 N 1,7 I 7,1 N 1,7 G 7,1 7,1 ! 1,7 !  4,1$nick is attempting to steal money from [lindex $text 0], quick someone help!!"
    }
  }
}

proc slot:pubm {nick uhost handle chan text} {
  global slot
  
  if {[slot_player_get $nick steal] != 0} {
    set info [slot_player_get $nick steal]
    set drop [rand 20]
    
    msg $chan "3,1\002$nick\002 has stopped \002[lindex $info 2]\002 from stealing their money!"
    
    # just so the wallet doesn't go into negatives, they drop what they have
    if {[slot_player_get [lindex $info 2] wallet] == 0} {
      set jail [rand 20]
      slot_player_set [lindex $info 2] jail [expr [clock seconds] + ($jail * 60)]
      msg $chan "4,1\002[lindex $info 2]\002 stumbled and has been caught by the police! $jail minutes in jail."
    } elseif {$drop > [slot_player_get [lindex $info 2] wallet]} {
      set drop [slot_player_get [lindex $info 2] wallet]
      slot_player_decr [lindex $info 2] wallet $drop
      msg $chan "4,1\002[lindex $info 2]\002 dropped \$$drop.00 as they were running away!"
    }
    
    
    slot_player_set $nick steal 0
    
  }
}
