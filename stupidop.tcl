set sb(version) "v1.0"
putlog "& Loading StupidOP $sb(version) ..."

if {[catch {
  package require mysqltcl

  set sb(cmd) "."
  set sb(seen.file) "seen.dat"

  source stupidop/util.tcl
  source stupidop/seen.tcl
  source stupidop/public.tcl
  source stupidop/admin.tcl
  source stupidop/core.tcl



} error]} {
  putlog "- FATAL ERROR: $error"
  putlog "* StupidOP could not be loaded."
}
