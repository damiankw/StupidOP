putlog " > Loading admin.tcl ..."
bind pub - $sb(cmd)system pub:system
bind pubm n *,* pub:cmd

proc pub:system {nick uhost handle chan text} {
  global uptime
  if {([catch {exec cat /proc/cpuinfo} cpuinfo]) || ([catch {exec uptime} uptime]) || ([catch {exec cat /proc/meminfo} meminfo])} {
    puthelp "PRIVMSG $chan :An error occured, stats can not be displayed."
  } else {
    set cpuinfo [split $cpuinfo \n]
    set stat(Vendor) [lindex [lindex $cpuinfo 1] 2]
    set stat(Model) [lrange [lindex $cpuinfo 4] 3 end]
    set stat(Freq) [lindex [lindex $cpuinfo 6] 3]

    set stat(load) [lrange $uptime [expr [llength $uptime] - 3] end]

    set meminfo [split $meminfo \n]
    

    putserv "PRIVMSG $chan :eggdrop;\[[duration [expr [unixtime] - $uptime]]\] server;\[[string trim [exec uptime] " "]\]";
    puthelp "PRIVMSG $chan :cpu;\[$stat(Model) (Load: $stat(load))\] mem;\[[expr [lindex [lindex $meminfo 1] 1] / 1024]/[expr [lindex [lindex $meminfo 0] 1] / 1024]Mb\]"
  }
}

proc pub:cmd {nick uhost handle chan text} {
  # <botnick>, <command> <args>
  # bots, <command> <args>
  global botnick
  if {([string tolower [lindex $text 0]] == "bots,") || ([string tolower [lindex $text 0]] == "[string tolower $botnick],")} {
    switch [lindex $text 1] {
      "rehash" {
        if {[catch {rehash} output]} {
          notice $nick "An error occurred while rehashing:"
          foreach line [split $ouptput \r\n] {
            notice $nick $line
          }
        } else {
          notice $nick "Successfully rehashed."
        }
      }
      "status" {
      }
      "load" {
        if {[catch {rehash} output]} {
          notice $nick "An error occurred while rehashing:"
          foreach line [split $ouptput \r\n] {
            notice $nick $line
          }
        } else {
          notice $nick "Successfully rehashed."
        }
      }
      "raw" {
        putquick [lrange $text 2 end]
        notice $nick "Put to server: [lrange $text 2 end]"
      }
      default {
        catch {eval [lrange $text 1 end]} output
        foreach line [split $output \r\n] {
          notice $nick "Tcl: $line"
        }
        notice $nick "End."
      }
    }
  }
}
