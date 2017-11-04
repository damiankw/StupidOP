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
  array_save slot slot.dat
  
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

# load the seen database if it exists
if {![array exists seen] && [file exists "seen.dat"]} {
  putlog ".. loading SEEN internal database (seen.dat)."
  source seen.dat
}

# load the slot database if it exists
if {![array exists slot] && [file exists "slot.dat"]} {
  putlog ".. loading SLOT internal database (slot.dat)."
  source slot.dat
}


proc slot_check {} {
  global slot
  # go through the current robberies and see if any have expired
  foreach item [array names slot *,steal] {
    if {$slot($item) == 0} {
      continue
    } elseif {[expr [lindex $slot($item) 0] + 300] < [clock seconds]} {
      msg [lindex $slot($item) 1] "[lindex $slot($item) 2] has stolen \$[lindex $slot($item) 4].00 from [lindex $slot($item) 3]!!!!!!"
      slot_player_decr [lindex $slot($item) 3] wallet [lindex $slot($item) 4]
      slot_player_incr [lindex $slot($item) 2] wallet [lindex $slot($item) 4]
      array unset slot $item
    }
  }
  
  if {![check_utimer slot_check]} {
    utimer 10 slot_check
  }
}

# check to see if the user has the variables required for no errors, create them if they don't
proc slot_player_check {user} { # updated
  global slot
  if {![info exists slot([string tolower $user],spent)]} {
    set slot([string tolower $user],spent) 0
  }

  if {![info exists slot([string tolower $user],won)]} {
    set slot([string tolower $user],won) 0
  }

  if {![info exists slot([string tolower $user],bank)]} {
    set slot([string tolower $user],bank) 0
  }
  
  if {![info exists slot([string tolower $user],wallet)]} {
    set slot([string tolower $user],wallet) 50
  }
  
  if {![info exists slot([string tolower $user],steal)]} {
    set slot([string tolower $user],steal) 0
  }
}

# check if the player has enough funds to do the command
proc slot_funds_check {user price} {
  if {[slot_player_get $user wallet] >= $price} {
    # the player has enough funds in their wallet
    return 1
  } elseif {[slot_player_get $user bank] >= $price} {
    # the player has funds in the bank, but needs to withdraw
    return -1
  } else {
    # the player doesn't have the funds at all
    return 0
  }
}

# get player items (wallet, bank, etc), easier than using $slot()
proc slot_player_get {user item} { # updated
  global slot
  
  if {![info exists slot([string tolower $user],[string tolower $item])]} {
    return 0
  } else {
    return $slot([string tolower $user],[string tolower $item])
  }
}

proc slot_player_set {user item value} {
  global slot
  
  set slot([string tolower $user],[string tolower $item]) $value
}

# increase the players item
proc slot_player_incr {user item {value 1}} {
  global slot
  
  incr slot([string tolower $user],[string tolower $item]) $value
}

# decrease the players item
proc slot_player_decr {user item {value 1}} {
  global slot
  
  incr slot([string tolower $user],$item) -$value
}

proc slot_incr {item {value 1}} {
  global slot
  
  incr slot([string tolower $item]) $value
}

# decrease the players item
proc slot_decr {item {value 1}} {
  global slot
  
  incr slot([string tolower $item]) $value
}

# set a variable
proc slot_set {item value} {
  global slot
  
  set slot([string tolower $item]) $value
}

proc slot_get {item} {
  global slot
  
  return $slot([string tolower $item])
}

slot_check

stupid_autosave