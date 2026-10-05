(* Word32Conv:WORD32CONV converts between Int32.int and Word32.word;
   see WORD32CONV.sig. *)
structure Word32Conv:>WORD32CONV=
struct
   (* The plain conversions are right only when bit 31 is clear *)
   fun fromInt32 i=
      if i<0
      then Word32.fromLargeInt(Int32.toLarge i + 0x100000000)
      else Word32.fromLargeInt(Int32.toLarge i)

   fun toInt32X w=
      if Word32.<(w,0wx80000000)
      then Int32.fromLarge(Word32.toLargeInt w)
      else Int32.fromLarge(Word32.toLargeInt w - 0x100000000)
end
