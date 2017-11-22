# load the script ..
putlog " > Loading seen.tcl ..."

# all of the triggers
bind pub - $sb(cmd)seen pub:seen
bind pub - $sb(cmd)top pub:top
bind pub - $sb(cmd)random pub:random

bind pubm - * seen:pubm
bind join - * seen:join
bind part - * seen:part
bind sign - * seen:sign
bind kick - * seen:kick
bind nick - * seen:nick
bind topc - * seen:topc

proc pub:seen {nick uhost handle chan text} {
  # .seen <nick> [-cmd <command>|-limit <num>|-chan <channel>]
  dccbroadcast "#SEEN# ($nick) $text"

  array set search [checkswitch $text "limit 1 cmd 2 chan 2" "full 0 limit 1 cmd * chan *"]
  set items [seen_search [lindex $search(text) 0] $search(chan) $search(cmd)]

  if {$search(text) == ""} {
    notice $nick "Invalid arguments: You need to enter a nickname."
  } elseif {$items == ""} {
    msg $chan "[lindex $search(text) 0] has not been seen."
  } elseif {$search(limit) == 1} {
    set snick [lindex [split [lindex [seen_get [lindex $items 0]] 1] "!"] 0]
    set shost [lindex [split [lindex [seen_get [lindex $items 0]] 1] "!"] 1]
    msg $chan "$snick ($shost) was last seen [seen_to_text [seen_get [lindex $items 0]] $search(full)]."
  } else {
    msg $chan "Found [llength $items] in the last [duration [expr ([clock seconds] - [lindex [split [lindex $items [expr ([llength $items] - 1)]] ","] 0])]] for [lindex $search(text) 0], showing $search(limit) in private."

    set count 1
    foreach item $items {
      set snick [lindex [split [lindex [seen_get [lindex $items 0]] 1] "!"] 0]
      set shost [lindex [split [lindex [seen_get [lindex $items 0]] 1] "!"] 1]

      if {($count > 10) || ($count > $search(limit))} {
        incr count 1
        continue
      }

      if {[lindex [seen_get $item] 0] == [clock seconds]} {
        continue
      }
      
      notice $nick "$snick ($shost) was seen [seen_to_text [seen_get $item] $search(full)]."

      incr count 1
    }
  }
}

proc pub:top {nick uhost handle chan text} {
  global stc
  # .top [-today|-yesterday|-week|-month|-alltime] [-lines|-words|-stats|-all] [-global|-chan <chan>] 
  # lines = top by lines
  # words = top by words
  # stats = top topics, kicker, kicked, joiner, (ops, deops)
  if {[lsearch "#melbourne #sydney" [string tolower $chan]] != -1} {
    return
  }

  array set args [checkswitch $text "limit 1 chan 2" "alltime 0 today 0 yesterday 0 week 0 month 0 all 0 lines 0 words 0 stats 0 help 0 limit 10 global 0 chan $chan"]
  set users(n/a) "n/a"
  set users(SERVER) "<server>"

  if {$args(help)} {
    notice $nick "SYNTAX for TOP: top -<today|yesterday|week|month|alltime> -<lines|words|stats|all> -<limit x> \[-<global|chan <channel>\]"
    return
  }
  
  if {$args(today)} {
    set date [clock scan [clock format [clock seconds] -format "%m/%d/%Y"]]
  } elseif {$args(yesterday)} {
    set date [clock scan [clock format [expr [clock seconds] - 86400] -format "%m/%d/%Y"]]
  } elseif {$args(week)} {
    set date [clock scan "last sunday"]
  } elseif {$args(month)} {
    set date [clock scan "[expr [clock format [clock seconds] -format %d] - 1] days ago"]
  } else {
    set date 0
  }
  
  if {!$args(all) && !$args(words) && !$args(stats)} {
    set args(lines) 1
  }
  
  if {$args(global)} {
    set target *
  } else {
    set target $args(chan)
  }
  
  foreach item [seen_search * $target] {
    if {[lindex [split $item ,] 0] < $date} {
      continue
    }
    set event [data_tidy [seen_get $item]]

    set user [string tolower [lindex [split [lindex $event 1] !] 0]]
    set users($user) [data_tidy [lindex [split [lindex $event 1] !] 0] 1]
    
    if {[lindex $event 2] == "TEXT"} {
      incr top_lines($user)
      incr top_words($user) [llength [lrange $event 4 end]]
    } elseif {[lindex $event 2] == "KICK"} {
      incr top_kick($user)
    } elseif {[lindex $event 2] == "KICKED"} {
      incr top_kicked($user)
    } elseif {[lindex $event 2] == "TOPIC"} {
      incr top_topic($user)
    } elseif {[lindex $event 2] == "JOIN"} {
      incr top_join($user)
    }
  }
  
  set top_lines_sorted [lsort -decreasing -integer -stride 2 -index 1 [array get top_lines]]
  set top_words_sorted [lsort -decreasing -integer -stride 2 -index 1 [array get top_words]]
  set top_kick_sorted [lsort -decreasing -integer -stride 2 -index 1 [array get top_kick]]
  if {[llength $top_kick_sorted] == 0} {
    set top_kick_sorted "n/a n/a"
  }
  set top_kicked_sorted [lsort -decreasing -integer -stride 2 -index 1 [array get top_kicked]]
  if {[llength $top_kicked_sorted] == 0} {
    set top_kicked_sorted "n/a n/a"
  }
  set top_topic_sorted [lsort -decreasing -integer -stride 2 -index 1 [array get top_topic]]
  if {[lindex $top_topic_sorted 0] == "*"} {
    set top_topic_sorted "SERVER [lrange $top_topic_sorted 1 end]"
  }
  set top_join_sorted [lsort -decreasing -integer -stride 2 -index 1 [array get top_join]]
  
  set top_lines_text [seen_top_text $top_lines_sorted [array get users] $args(limit)]
  set top_words_text [seen_top_text $top_words_sorted [array get users] $args(limit)]
  
  if {$args(lines) || $args(all)} {
    msg $chan "!!TOP($args(limit))-LINES!! $top_lines_text"
  }
  if {$args(words) || $args(all)} {
    msg $chan "!!TOP($args(limit))-WORDS!! $top_words_text"
  }
  if {$args(stats) || $args(all)} {
    msg $chan "!!TOP-STATS!! Kicks:\[$users([lindex $top_kick_sorted 0]):[lindex $top_kick_sorted 1]\] Kicked:\[$users([lindex $top_kicked_sorted 0]):[lindex $top_kicked_sorted 1]\] Topic Changes:\[$users([lindex $top_topic_sorted 0]):[lindex $top_topic_sorted 1]\] Joins:\[$users([lindex $top_join_sorted 0]):[lindex $top_join_sorted 1]\]"
  }

}

proc pub:random {nick uhost handle chan text} {
  if {[lsearch "#melbourne #sydney" [string tolower $chan]] != -1} {
    return
  }

  if {$text == ""} {
    set rand [seen_get [lindex [seen_search * * text] [rand [llength [seen_search * * text]]]]]
    msg $chan "<[lindex [split [lindex $rand 1] ,] 0]> [lrange $rand 4 end]"
  } else {
    set rand [seen_get [lindex [seen_search $text * text] [rand [llength [seen_search $text * text]]]]]
    msg $chan "<[lindex [split [lindex $rand 1] ,] 0]> [lrange $rand 4 end]"

  }
}

proc seen:pubm {nick uhost handle chan text} {
  seen_add $nick!$uhost TEXT "$chan $text"
}

proc seen:join {nick uhost handle chan} {
  seen_add $nick!$uhost JOIN $chan
}

proc seen:part {nick uhost handle chan text} {
  seen_add $nick!$uhost PART "$chan $text"
}

proc seen:sign {nick uhost handle chan text} {
  seen_add $nick!$uhost QUIT "* $text"
}

proc seen:kick {nick uhost handle chan knick text} {
  seen_add $nick![getchanhost $nick] KICK "$chan $knick $text"
  seen_add $knick![getchanhost $knick] KICKED "$chan $nick $text"
}

proc seen:nick {nick uhost handle chan newnick} {
  seen_add $nick!$uhost NICK "$chan $newnick"
}

proc seen:topc {nick uhost handle chan text} {
  seen_add $nick!$uhost TOPIC "$chan $text"
}












##### development after this
proc seen_to_sql {} {
  global seen
  set sql [::mysql::connect -host localhost -user damian -password 43DA0887 -db damian]

  set query [::mysql::query $sql "SELECT `date`, `user`, `type`, `info`  FROM seen ORDER BY date DESC LIMIT 1"]
  
  set row [::mysql::fetch $query]
  
  set date [lindex $row 0]

  set total 0
  foreach item [array names seen] {
    if {[lindex [split $item ,] 0] > $date} {
      set data [data_tidy [seen_get $item]]
      ::mysql::exec $sql "INSERT INTO seen (`date`, `user`, `type`, `info`) VALUES('[lindex $data 0]', '[data_tidy [lindex $data 1] 2]', '[lindex $data 2]', '[data_tidy [lrange $data 3 end] 2]')"
      incr total 1
    }
  }

  return $total
}

proc seen_to_stat {} {
  # goes through all of the seen data and converts it into statistics
  
  # get most text
  # get longest string
  # get most joins
  # get 
  
  global seen stat_user stat_text stat_join stat_part stat_quit stat
  foreach item [array names seen *,*,text] {
    set item_data [data_tidy [seen_get $item]]

    if {![info exists stat_text([lindex [split $item ,] 1],lines)]} {
      set stat_user([lindex [split $item ,] 1]) [data_tidy [lindex $item_data 1] 1]
      set stat_text([lindex [split $item ,] 1],lines) 0
      set stat_text([lindex [split $item ,] 1],words) 0
      set stat_text([lindex [split $item ,] 1],letters) 0
    }

    incr stat_text([lindex [split $item ,] 1],lines) 1
    incr stat_text([lindex [split $item ,] 1],words) [llength [lrange $item_data 4 end]]
    incr stat_text([lindex [split $item ,] 1],letters) [string length [lrange $item_data 4 end]]
  }

  foreach item [array names stat_user] {
    set nick [lindex [split $item ,] 0]
    dccbroadcast "Statistics for $stat_user($nick): lines:($stat_text($nick,lines)) words:($stat_text($nick,words)) letters:($stat_text($nick,letters))"
  }
}


##################################################

