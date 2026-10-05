(*======================================================================*)
(* Hello, world                                                         *)
(*======================================================================*)
structure Hello :>
sig
  val main : unit -> unit
end
=
struct

fun main () = print "Hello from SML.NET!\n"

end
