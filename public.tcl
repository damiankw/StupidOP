bind pub - $sb(cmd)help pub:help
bind pub - $sb(cmd)commands pub:commands
bind pub - $sb(cmd)gamble pub:gamble
bind pub - $sb(cmd)cash pub:cash
bind pub - $sb(cmd)bank pub:bank
bind pub - $sb(cmd)rob pub:rob
bind pub - $sb(cmd)jackpot pub:jackpot
bind pubm - * slot:pubm

array set slot_items "bell {1,10 [align "BELL" 10 " " C] } cherry {1,5 [align "CHERRY" 10 " " C] } plum {1,6 [align "PLUM" 10 " " C] } weed {1,9 [align "WEED" 10 " " C] } strawberry {0,4 [align "STRAWBERRY " 10 " " C] } coal {0,1 [align "COAL" 10 " " C] } blueberry {1,11 [align "BLUEBERRY" 10 " " C] } orange {1,7 [align "ORANGE" 10 " " C] } apple {4,3 [align "APPLE" 10 " " C] } banana {1,8 [align "BANANA" 10 " " C] }"

proc pub:help {nick uhost handle chan text} {
  if {[lindex $text 0] == ""} {
    notice $nick "*** Commands List for StupidOP ***"
    notice $nick ".gamble : Gamble on the pokies"
    notice $nick ".cash   : See how much cash you/someone else has"
    notice $nick ".rob    : Rob another players cash"
    notice $nick ".seen   : Check when a user was last seen"
    notice $nick ".top    : Check the top statistics"
    notice $nick ".random : Say a random line of a user"
    notice $nick "For more information on any command, visit https://stupid.nictitate.net/ or use: .help <command>"
    notice $nick "*** End of List ***"
  } elseif {[string trim [string tolower [lindex $text 0]] .] == "gamble"} {
    notice $nick "Usage: .gamble"
    notice $nick "     - Runs the pokies for \$1.00 and gives you the change to in the JACKPOT!"
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?gamble"
  } elseif {[string trim [string tolower [lindex $text 0]] .] == "cash"} {
    notice $nick "Usage: .cash \[<nick>\]"
    notice $nick "     - Shows the current cash for the player (or yourself if no player is specified)"
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?cash"
  } elseif {[string trim [string tolower [lindex $text 0]] .] == "rob"} {
    notice $nick "Usage: .rob <nick>"
    notice $nick "     - Attempts to rob the player from their wallet. They have five minutes to say anything in the channel to stop you."
    notice $nick "     - If the player stops you, you will drop cash, even if you have none! BEWARE!"
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?rob"
  } elseif {[string trim [string tolower [lindex $text 0]] .] == "seen"} {
    notice $nick "Usage: .seen <nick> \[-cmd <command>|-limit <num>|-chan <chan>\]"
    notice $nick "     - Attempt to find when the user was last active on the network, the switches will specify search parameters. Defaults to all commands and all channels with a limit of 1."
    notice $nick "     % -cmd <command> : Search only the command queried, valid commands are TEXT|JOIN|PART|QUIT|NICK|KICK|KICKED"
    notice $nick "     % -limit <num>   : Return this number of search results, maximum is 10."
    notice $nick "     % -chan <chan>   : Search only in the channel queried."
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?seen"
  } elseif {[string trim [string tolower [lindex $text 0]] .] == "top"} {
    notice $nick "Usage: .top \[-today|-yesterday|-week|-month|-alltime\] \[-lines|-words|-stats|-all\] \[-global|-chan <chan>\]"
    notice $nick "     - Display the top chatters through the history. Default is the top lines for all time on the current channel."
    notice $nick "     % -<date field> : Display statistics for the period queried."
    notice $nick "     % -<type>       : Displays the statistics queried."
    notice $nick "     % -global       : Displays statistics for all channels."
    notice $nick "     % -chan <chan>  : Displays statistics for the channel queried."
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?top"
  } elseif {[string trim [string tolower [lindex $text 0]] .] == "random"} {
    notice $nick "Usage: .random \[<nick>\]"
    notice $nick "     - Displays a random line from nick. If no nick is specified, it chooses a random line from everyone."
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?random"
  } elseif {[string trim [string tolower [lindex $text 0]] .] == "bank"} {
    notice $nick "Usage: .bank \[<amount>\]"
    notice $nick "     - Banks the amount so no one can steal it from you without a group effort vault break. If no amount is specified, it will bank all of your cash."
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?bank"
  } elseif {[string trim [string tolower [lindex $text 0]] .] == ""} {
    notice $nick "For more information, visit https://stupid.nictitate.net/command.php?seen"
  } else {
    pub:help $nick $uhost $handle $chan ""
  }
}

proc pub:commands {nick uhost handle chan text} {
  pub:help $nick $uhost $handle $chan $text
}

proc pub:gamble {nick uhost handle chan text} {
  global slot slot_items
  
  # configure the player defaults if they don't already exist
  slot_player_check $nick
  
  # check if the user has money to play
  if {[slot_funds_check $nick 1] == -1} {
    notice $nick "You don't have enough funds in your wallet for this, please withdraw from the bank!"
  } elseif {[slot_funds_check $nick 1] == 0} {
    notice $nick "You don't have enough funds in your wallet or in the bank for this, go raise some cash!"
  } else {
    # spin up the slots
    set item(1) $slot_items([lindex [array names slot_items] [rand [llength [array names slot_items]]]])
    set item(2) $slot_items([lindex [array names slot_items] [rand [llength [array names slot_items]]]])
    set item(3) $slot_items([lindex [array names slot_items] [rand [llength [array names slot_items]]]])

    # set the start message
    set msg "1,10 ! 1,5 ! 1,6 G 1,9 A 0,4 M 0,1 B 1,11 L 1,7 E 4,3 ! 1,8 !    :::   \[JACKPOT: \$$slot(jackpot).00\]   :::   \[ $item(1) | $item(2) | $item(3) \]   :::  "

    # it costs $1
    slot_player_incr $nick spent 1
    slot_player_decr $nick wallet 1

    if {($item(1) == $item(2)) && ($item(2) == $item(3))} {
      # we have a winner!
      set msg "$msg 0 1,8 J 1,4 A 1,9 C 1,7 K 1,13 P 1,11 O 1,5 T    !!! $nick just won $slot(jackpot) points!!!"
      slot_incr winners
      slot_player_incr $nick won [slot_get jackpot]
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
  notice $nick "Current Jackpot:\[\$[slot_get jackpot].00\] Last Jackpot:\[\$[slot_get last.jackpot].00\] Last Winner:\[[slot_get last.winner]\] Total Winners:\[[slot_get winners]\]"
}

proc pub:cash {nick uhost handle chan text} {
  global slot
  if {[lindex $text 0] == ""} {
    set user $nick
  } else {
    set user [lindex $text 0]
  }
  
  notice $nick "Amount Won:\[\$[slot_player_get $user won].00\] Amount Spent:\[\$[slot_player_get $user spent].00\] Wallet:\[\$[slot_player_get $user wallet].00\] Bank:\[\$[slot_player_get $user bank].00\]"
}

proc pub:bank {nick uhost handle chan text} {
  global slot
  if {[lindex $text 0] == ""} {
    set bank [slot_player_get $nick wallet]
  } else {
    set bank [string trim [lindex [split $text .] 0] "\$"]
  }
  
  if {[slot_player_get $nick wallet] == 0} {
    notice $nick "You currently nothing in your wallet, you can't bank."
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
    msg $chan "0,1 ! 1,0 ! 0,1 B 1,0 A 0,1 N 1,0 K 0,1 ! 1,0 !  $nick has banked \$$bank.00, leaving \$[slot_player_get $nick wallet].00 in their wallet."
  }
}

proc pub:rob {nick uhost handle chan text} {
  global slot
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
    
    # just so the wallet doesn't go into negatives, they drop what they have
    if {$drop > [slot_player_get [lindex $info 2] wallet]} {
      set drop [slot_player_get [lindex $info 2] wallet]
    }
    
    msg $chan "3,1\002$nick\002 has stopped \002[lindex $info 2]\002 from stealing their money!"
    msg $chan "4,1\002[lindex $info 2]\002 dropped \$$drop.00 as they were running away!"
    
    slot_player_decr [lindex $info 2] wallet $drop
    slot_player_set $nick steal 0
  }
}

if {![info exists slot(jackpot)]} {
  set slot(jackpot) [rand 200]
  set slot(winners) 0
  set slot(last.winner) "n/a"
  set slot(last.jackpot) "0"
}
