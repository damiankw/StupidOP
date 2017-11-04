# check if 
proc isnum {num} {
  if {$num == ""} {
    return 0
  }
  foreach char [split $num ""] {
    if {![string match \[0-9\] $char] && $char != "."} {
      return 0
    }
  }
  return 1
}

### checkswitch: checkswitch <text> <switches> <defaults>
# - 'switches' should only include switches with arguments -- 1 (num); 2 (text)
# Will check 'text' for any 'switches' and return an array of results.
proc checkswitch {text switchlist {default {}}} {
  array set output $default
  array set switch $switchlist
  set output(text) ""
  set skip 0

  foreach word $text {
    if {$skip} {
      set skip 0
    } elseif {([lindex [split $word ""] 0] == "-") && ([array names switch [string tolower [string trimleft $word "-"]]] != "")} {
      set nextword [lindex $text [expr [lsearch $text $word] + 1]]
      
      if {([lindex [split $nextword ""] 0] == "-")} {
        continue
        
      } elseif {([isnum $nextword]) && ($switch([string tolower [string trimleft $word "-"]]) == 1)} {
        set output([string tolower [string trimleft $word "-"]]) [lindex $text [expr [lsearch $text $word] + 1]]
        set skip 1
        
      } elseif {($switch([string tolower [string trimleft $word "-"]]) == 2)} {
        set output([string tolower [string trimleft $word "-"]]) [lindex $text [expr [lsearch $text $word] + 1]]
        set skip 1
      }
    } elseif {[lindex [split $word ""] 0] == "-"} {
      set output([string tolower [string trimleft $word "-"]]) 1
      
    } else {
      set output(text) "$output(text) $word"
      
    }
  }

  set output(text) [string trim $output(text)]
  return [array get output]
}



proc int {num} {
  return [lindex [split $num "."] 0]
}

proc array_save {array file} {
  eval global $array
  if {[file exists $file]} {
    file delete $file
  }
  set wfile [open $file w]
  puts $wfile "# Array Database Backup for $array -- written [clock format [clock seconds] -format "%a %b %d %H:%M:%S %Y"]"
  puts $wfile "global $array"
  puts $wfile [list array set $array [array get $array]]
  close $wfile
}

proc duration {num {type "1"}} {
  if {$type == "1"} {
    set tmp(1) [int $num]
    set tmp(wks) " [int [expr $tmp(1) /60/60/24/7]]wks"
    if {$tmp(wks) == " 0wks"} {
      set tmp(wks) ""
    }
    incr tmp(1) -[int [expr [int [expr $tmp(1) /60/60/24/7]] *7*24*60*60]]
    set tmp(days) " [int [expr $tmp(1) /60/24/60]]days"
    if {$tmp(days) == " 0days"} {
      set tmp(days) ""
    }
    incr tmp(1) -[int [expr [int [expr $tmp(1) /60/24/60]] *60*24*60]]
    set tmp(hrs) " [int [expr $tmp(1) /60/60]]hrs"
    if {$tmp(hrs) == " 0hrs"} {
      set tmp(hrs) ""
    }
    incr tmp(1) -[int [expr [int [expr $tmp(1) /60/60]] *60*60]]
    set tmp(mins) " [int [expr $tmp(1) /60]]mins"
    if {$tmp(mins) == " 0mins"} {
      set tmp(mins) ""
    }
    incr tmp(1) -[int [expr [int [expr $tmp(1) /60]] *60]]
    set tmp(secs) " $tmp(1)secs"
    if {$tmp(secs) == " 0secs"} {
      set tmp(secs) ""
    }
    return [string trimleft "$tmp(wks)$tmp(days)$tmp(hrs)$tmp(mins)$tmp(secs)"]
  } elseif {$type == "2"} {
    set tmp(1) [int $num]
    set tmp(wks) " [int [expr $tmp(1) /60/60/24/7]] Weeks"
    if {$tmp(wks) == " 0 Weeks"} {
      set tmp(wks) ""
    }
    incr tmp(1) -[int [expr [int [expr $tmp(1) /60/60/24/7]] *7*24*60*60]]
    set tmp(days) " [int [expr $tmp(1) /60/24/60]] Days"
    if {$tmp(days) == " 0 Days"} {
      set tmp(days) ""
    }
    incr tmp(1) -[int [expr [int [expr $tmp(1) /60/24/60]] *60*24*60]]
    set tmp(hrs) " [int [expr $tmp(1) /60/60]] Hours"
    if {$tmp(hrs) == " 0 Hours"} {
      set tmp(hrs) ""
    }
    incr tmp(1) -[int [expr [int [expr $tmp(1) /60/60]] *60*60]]
    set tmp(mins) " [int [expr $tmp(1) /60]] Minutes"
    if {$tmp(mins) == " 0 Minutes"} {
      set tmp(mins) ""
    }
    incr tmp(1) -[int [expr [int [expr $tmp(1) /60]] *60]]
    set tmp(secs) " $tmp(1) Seconds"
    if {$tmp(secs) == " 0 Seconds"} {
      set tmp(secs) ""
    }
    return [string trimleft "$tmp(wks)$tmp(days)$tmp(hrs)$tmp(mins)$tmp(secs)"]
  } elseif {($type == "3") || ($type == "4")} {
    set tmp(1) [int $num]
    if {$type == 3} {
      set tmp(days) "[int [expr $tmp(1) /60/24/60]] days, "
    } elseif {$type == 4} {
      set tmp(days) "[int [expr $tmp(1) /60/24/60]] d "
    }
    incr tmp(1) -[int [expr [int [expr $tmp(1) /60/24/60]] *60*24*60]]
    set tmp(hrs) [align [int [expr $tmp(1) /60/60]] 2 0 R]
    incr tmp(1) -[int [expr [int [expr $tmp(1) /60/60]] *60*60]]
    set tmp(mins) [align [int [expr $tmp(1) /60]] 2 0 R]
    incr tmp(1) -[int [expr [int [expr $tmp(1) /60]] *60]]
    set tmp(secs) [align $tmp(1) 2 0 R]
    return "$tmp(days)$tmp(hrs):$tmp(mins):$tmp(secs)"
  } elseif {$type == "5"} {
    set tmp(1) [int $num]
    set tmp(days) [int [expr $tmp(1) /60/24/60]]
    incr tmp(1) -[int [expr [int [expr $tmp(1) /60/24/60]] *60*24*60]]
    set tmp(hrs) [align [int [expr $tmp(1) /60/60]] 2 0 R]
    incr tmp(1) -[int [expr [int [expr $tmp(1) /60/60]] *60*60]]
    set tmp(mins) [align [int [expr $tmp(1) /60]] 2 0 R]
    incr tmp(1) -[int [expr [int [expr $tmp(1) /60]] *60]]
    set tmp(secs) [align $tmp(1) 2 0 R]
    return [string trimleft "$tmp(days) d, $tmp(hrs) h, $tmp(mins) m, $tmp(secs) s"]
  }
}


proc msg {target text} {
  putserv "PRIVMSG $target :$text"
}

proc notice {target text} {
  putserv "NOTICE $target :$text"
}

proc replace {text tok rep} {
  set atext ""
  foreach char [split $text ""] {
    if {$char == $tok} {
      set atext $atext$rep
    } else {
      set atext $atext$char
    }
  }
  return $atext
}

# 0 = convert into // | 1 = convert back | 2 convert to sql
proc data_tidy {text {type 0}} {
  if {$type == 0} {
    regsub -all {\{} $text "/123/" text
    regsub -all {\}} $text "/125/" text
    regsub -all {\\} $text "/092/" text
    regsub -all {\[} $text "/091/" text
    regsub -all {\]} $text "/093/" text
    regsub -all {\;} $text "/059/" text
    regsub -all {\)} $text "/041/" text
    regsub -all {\(} $text "/040/" text
    regsub -all {\'} $text "/039/" text
    regsub -all {\%} $text "/037/" text
    regsub -all {\$} $text "/036/" text
    regsub -all {\#} $text "/035/" text
    regsub -all {\"} $text "/034/" text
    regsub -all {\} $text "/031/" text
    regsub -all {\} $text "/022/" text
    regsub -all {\} $text "/004/" text
    regsub -all {\} $text "/003/" text
    regsub -all {\} $text "/002/" text
  } elseif {$type == 1} {
    regsub -all {/123/} $text "\{" text
    regsub -all {/125/} $text "\}" text
    regsub -all {/092/} $text "\\" text
    regsub -all {/091/} $text "\[" text
    regsub -all {/093/} $text "\]" text
    regsub -all {/059/} $text "\;" text
    regsub -all {/041/} $text "\)" text
    regsub -all {/040/} $text "\(" text
    regsub -all {/039/} $text "\'" text
    regsub -all {/037/} $text "\%" text
    regsub -all {/036/} $text "\$" text
    regsub -all {/035/} $text "\#" text
    regsub -all {/034/} $text "\"" text
    regsub -all {/031/} $text "\" text
    regsub -all {/022/} $text "\" text
    regsub -all {/004/} $text "\" text
    regsub -all {/003/} $text "\" text
    regsub -all {/002/} $text "\" text
  } elseif {$type == 2} {
    regsub -all {/123/} $text "\\\{" text
    regsub -all {/125/} $text "\\\}" text
    regsub -all {/092/} $text "\\\\\\" text
    regsub -all {/091/} $text "\\\[" text
    regsub -all {/093/} $text "\\\]" text
    regsub -all {/059/} $text "\\\;" text
    regsub -all {/041/} $text "\\\)" text
    regsub -all {/040/} $text "\\\(" text
    regsub -all {/039/} $text "\\\'" text
    regsub -all {/037/} $text "\\\%" text
    regsub -all {/036/} $text "\\\$" text
    regsub -all {/035/} $text "\\\#" text
    regsub -all {/034/} $text "\\\"" text
    regsub -all {/031/} $text "\\\" text
    regsub -all {/022/} $text "\\\" text
    regsub -all {/004/} $text "\\\" text
    regsub -all {/003/} $text "\\\" text
    regsub -all {/002/} $text "\\\" text
  }
  return $text
}


proc align {text num {char " "} {type "L"}} {
  set a ""
  set b 1
  set text [data_tidy $text 1]
  while {$b <= [expr $num - [string length $text]]} {
    set a $a$char
    incr b 1
  }
  if {[string toupper $type] == "R"} {
    return $a$text
  } elseif {[string toupper $type] == "L"} {
    return $text$a
  } elseif {[string toupper $type] == "C"} {
    return [string range $a 0 [expr [string length $a] / 2]]$text[string range $a [expr [string length $a] / 2] end]
  }
}
