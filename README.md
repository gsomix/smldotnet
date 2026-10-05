SML.NET
=======

SML.NET   is  a   compiler   for  the   functional
programming language Standard  ML that targets the
.NET  Common Language  Runtime and  which supports
language interoperability features for easy access
to .NET libraries.

Status
------

This  project  is  now defunct  and  what  follows
applies  to the  last  stable release  as of  2006
which is also the state of the current tree.

The 2006 release supported the .NET Framework 2.0 and lower. 
This tree targets modern .NET instead (see "Targeting .NET"
below).

Although SML.NET fully  supports SML polymorphism,
it does not yet produce or consume .NET generics

Building with SML/NJ
--------------------

The compiler builds with SML/NJ 110.99.9. On Linux
or macOS run

```
bld/buildsmlnet.sh
```

to produce the heap image `bin/smlnet.<arch>-<os>`
and the .NET tools (see below), then start the
compiler with `bin/smlnet.sh`. Set
`SMLNJ_HOME` to use an SML/NJ installation that is
not on the `PATH`. The lexer is generated with the
legacy `ml-lex` (installed with SML/NJ), so it must
be on the `PATH` when building.

Several of the changes for newer SML/NJ are based
on the work of Darin Minamoto ([@DarinM223]) in
his fork https://github.com/DarinM223/smldotnet:

* `Substring.all` is replaced by `Substring.full`,
  and the GC time is read with `Timer.checkGCTime`,
  following [922f305] on his `legacy` branch (which
  builds SML.NET with 32-bit SML/NJ 110.99.4).
* `Numbers.sml` accepts integers of up to 64 bits,
  with range checks in `isi4` and `isu4`, following
  [8c238e1] on his `master` branch.

[@DarinM223]: https://github.com/DarinM223
[922f305]: https://github.com/DarinM223/smldotnet/commit/922f305cfc701dc5eb17db22a43214a98a42353d
[8c238e1]: https://github.com/DarinM223/smldotnet/commit/8c238e136fbcc193eb3e3038bd616212015dfc6b

Targeting .NET
--------------

Building requires the .NET 10 SDK (`dotnet` on the
`PATH`). `bld/buildsmlnet.sh` runs
`dotnet build src/clr/tools/tools.slnx`, which builds
`getmeta` and `clslist` (`src/clr/*.cs`) and fetches
`ilasm`, `ILVerify` and the .NET Standard 2.0
reference assemblies from NuGet:

```
bin/tools/               getmeta.dll, clslist.dll, ilasm, ILVerify.dll
bin/ref/netstandard2.0/  netstandard.dll and facades
```

SML.NET compiles against `netstandard.dll`, so its
libraries work with any .NET Standard 2.0 consumer.
Executables get a `.runtimeconfig.json` for .NET 10
or later and run with `dotnet`:

```
cd demos/hello
../../bin/smlnet.sh Hello
dotnet Hello.exe
```

The compiler's `run` command also uses `dotnet`; set
`SMLNETRUN` to use something else. To run an
executable, copy the assemblies it references, other
than the .NET Standard ones, next to it. With
`codegen.verify` on, as in `bin/config.smlnet`, the
compiler checks its output with ILVerify.

Features
--------

* Support all of Standard ML

SML.NET compiles  all of  SML '97 (with  some very
minor discrepancies).

* Support for the Basis library

Almost  all of  the Standard  ML Basis  Library is
implemented.

* Seamless  interoperability with  other languages

SML.NET extends the SML  language to support safe,
convenient use of the .NET Framework libraries and
code written in other  languages for the CLR, such
as C# or VB. SML.NET  can both consume and produce
.NET classes, interfaces, delegates etc.

* Command-line compilation

SML.NET supports traditional  compilation from the
command-line. Interactive  compilation environment
Alternatively, you  can control the  compiler from
an  interactive  environment.  This lets  you  set
and  query options  incrementally and  to see  the
signatures  of   compiled  and   imported  SML.NET
modules.

* Automatic dependency analysis

In  either  mode   of  compilation,  the  compiler
requires  only the  names  of root  modules and  a
place  to  look  for  source code.  It  then  does
dependency analysis  to determine which  files are
required and which need recompilation.

* Produces verifiable CLR IL

The  output of  the  compiler  is verifiable  MSIL
(Microsoft Intermediate Language) for the CLR.

* Whole program optimization

SML.NET performs optimizations  on a whole program
(or library)  at once.  It usually  produces small
executables with fairly good performance.

* Integration with Visual Studio .NET

A   separate  binary   distribution  includes   an
experimental package  for Microsoft  Visual Studio
.NET  2002, 2003  and &  2005 that  allows you  to
edit, build and debug SML.NET projects from within
the development environment.

Limitations
-----------

* No interactive evaluation

The interactive environment  is for compilation of
stand-alone  applications or  libraries only.  SML
expressions can not be evaluated interactively and
the  use command  is not  available. For  programs
that make no use of  the language extensions it is
possible to develop and test them using a compiler
such as Moscow ML or Standard ML of New Jersey and
then to use SML.NET to produce final executables.

* Whole program optimization

Top-level   SML    modules   are    not   compiled
individually  to .NET  object code.  Instead, some
compilation takes place  on separate modules (type
checking,  translation   to  the   compiler's  own
intermediate  form,  and some  optimizations)  but
most is deferred until  after the linking together
of top-level modules. This improves performance of
the  generated code,  but significantly  increases
(re)compilation times.

* Only CLR types at boundaries of compiled code

The  exposed interfaces  of  applications or  DLLs
compiled by  SML.NET may  only refer to  CLR types
(classes,   interfaces,  delegates,   etc.).  They
may  not  expose  SML-specific  types  (functions,
datatypes,  records,  etc.). In  particular,  this
restriction  means  that  one  cannot  compile  an
arbitrary SML  module into  a DLL  for consumption
even by  other SML.NET  programs: the  module must
be  either  linked  into  the  client  program  at
compile-time  or   use  only  CLR  types   at  its
interface.

