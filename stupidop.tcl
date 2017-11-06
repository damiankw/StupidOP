set sb(version) "v1.0"
putlog "& Loading StupidOP $sb(version) ..."

if {[catch {
  package require mysqltcl

  set sb(cmd) "."
  set sb(path) "/home/damian/eggdrop/stupidop/"
  set sb(seen.file) "seen.dat"
  set sb(game.file) "game.dat"
  set sb(joke.file) "joke.txt"

  source stupidop/util.tcl
  source stupidop/seen.tcl
  source stupidop/public.tcl
  source stupidop/admin.tcl
  source stupidop/core.tcl

} error]} {
  foreach line [split $errorInfo \n] {
    putlog " % $line"
  }
  putlog "& StupidOP could not be loaded."
} else {
  putlog "& StupidOP loaded successfully."
}
