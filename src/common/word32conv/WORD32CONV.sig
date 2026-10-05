(* Word32Conv:WORD32CONV converts between Int32.int and Word32.word
   modulo 2^32, like Word32.fromInt and Word32.toIntX.

   64-bit SML/NJ 110.99.9 compiles Word32.fromLargeInt o Int32.toLarge
   and Int32.fromLarge o Word32.toLargeIntX to the identity, which is
   wrong when bit 31 is set: Word32.fromLargeInt (Int32.toLarge ~1) is
   0wx7FFFFFFFFFFFFFFF.  Reported as item 9 of
   https://github.com/smlnj/legacy/issues/387 (closed without a fix).
   *)
signature WORD32CONV=
sig
   val fromInt32:Int32.int->Word32.word
   val toInt32X:Word32.word->Int32.int
end
