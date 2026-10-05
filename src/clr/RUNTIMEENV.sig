(*======================================================================*)
(* Info about the runtime environment					*)
(*======================================================================*)
signature RUNTIMEENV =
sig

(* Set up the compiler/runtime environment: 
     determine compiler binary directory
     determine target framework (e.g. netstandard2.0)
     determine reference assembly directory
     check presence of compiler tools (getmeta, clslist)
     check presence of assembler tools (ilasm, ILVerify)
  If there are any problems, print to console and return false
*)
val setup : {SMLNETPATH:string,FrameworkDir:string,FrameworkVersion:string} option -> bool 

(* Query functions for info picked up by setup. Exception will be raised if setup hasn't been run *)

(* The reference assembly directory (e.g. $SMLNETPATH/bin/ref/netstandard2.0) *)
val getSysDir : unit -> string

(* The target framework (e.g. netstandard2.0) *)
val getVersion : unit -> string 

(* Are we using the compiler-shipped version of ilasm? *)
val getCompilerIlasm : unit -> bool

(* The compiler directory (e.g. C:\smlnet) *)
val getCompilerDir : unit -> string

(* The compiler binary directory (e.g. C:\smlnet\bin) *)
val getCompilerBinDir : unit -> string

(* The metadata cache directory (e.g. $SMLNETPATH/bin/netstandard2.0) *)
val getCompilerToolDir : unit -> string

(* Full path to getmeta tool (e.g. $SMLNETPATH/bin/tools/getmeta.dll) *)
val getGetmetaFileName : unit -> string

(* Full path to clslist tool (e.g. $SMLNETPATH/bin/tools/clslist.dll) *)
val getClslistFileName : unit -> string

(* Full path to ilasm tool (e.g. $SMLNETPATH/bin/tools/ilasm) *)
val getIlasmFileName : unit -> string

(* Full path to ILVerify (e.g. $SMLNETPATH/bin/tools/ILVerify.dll) *)
(* If it doesn't exist, return NONE *)
val getPeverifyFileName : unit -> string option

(* Run a helper program *)
val runHelper : { program : string, args : string, out : string } -> OS.Process.status

(* Run a managed program *)
val run : { program : string, args : string } -> OS.Process.status

(* Write the .runtimeconfig.json that dotnet needs to run an executable *)
val writeRuntimeConfig : string -> bool

end

