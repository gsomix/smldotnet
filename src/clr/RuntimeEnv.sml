(*======================================================================*)
(* Info about the runtime environment					*)
(* See signature for more details.                                      *)
(*======================================================================*)
structure RuntimeEnv :> RUNTIMEENV
= 
struct

val defaultFrameworkVersion = "netstandard2.0"
val runtimeTfm = "net10.0"
val runtimeFrameworkVersion = "10.0.0"

val frameworkVersion = ref ""
val compilerDir = ref ""
val compilerBinDir = ref ""
val compilerToolDir = ref "" (* compilerBinDir ^ "/" ^ frameworkVersion *)
val runtimeSysDir = ref ""
val runtimeVersion = ref ""
val setupWasRun = ref false

val getmetaFileName = ref ""
val clslistFileName = ref ""
val ilasmFileName = ref ""
val peverifyFileName = ref (NONE : string option)
val compilerIlasm = ref false

fun failWith message = (PrintManager.println message; false)

(* If set, display a message when helper executables are run *)
val showHelperExecs = Controls.add false "env.showHelpers"

fun quote s = "\"" ^s^ "\""

(* Execute a managed program with specified arguments *)
fun run { program, args } =
let
  (* If defined, SMLNETRUN is used instead of dotnet *)
  val prefix = 
    case OS.Process.getEnv "SMLNETRUN" of
      NONE => "dotnet "
    | SOME s => s ^ " "
  val command = prefix ^ program ^ " " ^ args
  val result = OS.Process.system command
in
  if result = OS.Process.success 
  then ()
  else PrintManager.println ("Error occurred while running " ^ command ^ "\n");
  result
end

(* Execute a managed helper program *)
fun runHelper { program, args, out } =
let
  val args = args ^ " " ^ quote out
in
  if Controls.get showHelperExecs 
  then PrintManager.println ("[" ^ program ^ " " ^ args ^ "]") else ();
  run { program=program, args=args }
end

fun trySet (r : string ref, s : string) =
  if OS.FileSys.access(s, [])
  then (r := s; true)
  else failWith ("Cannot find " ^ s)

fun tryGet r =
  if !setupWasRun then !r
  else raise Fail "RuntimeEnv.tryGet: setup has not been run successfully"


fun writeFile(dst,s) = 
    let val os = TextIO.openOut dst 
    in
        TextIO.output(os,s);
        TextIO.closeOut(os);
        true
    end handle _ => (PrintManager.println("Failed to write file " ^ dst); false)

fun toolsDir () = OS.Path.concat(!compilerBinDir, "tools")


(* The parent of the directory holding the heap image, i.e. of bin.
   The last @SMLload argument is the heap that the runtime loaded. *)
fun heapCompilerDir () =
  let
    val prefix = "@SMLload="
    val loads = List.filter (String.isPrefix prefix) (SMLofNJ.getAllArgs ())
  in
    case rev loads of
      [] => NONE
    | load::_ =>
      let
        val heap = String.extract(load, size prefix, NONE)
        val binDir = case OS.Path.dir heap of "" => OS.Path.currentArc | dir => dir
      in
        SOME (OS.Path.getParent (OS.FileSys.fullPath binDir))
      end
      handle OS.SysErr _ => NONE
  end

fun setupRuntimeInfo arg =
  case arg of
    SOME {SMLNETPATH,FrameworkDir,FrameworkVersion} =>
    (frameworkVersion := FrameworkVersion;
     runtimeVersion := FrameworkVersion;
     trySet(compilerDir, PathConv.toInternal SMLNETPATH) andalso
     trySet(compilerBinDir, OS.Path.concat(!compilerDir, "bin")) andalso
     trySet(runtimeSysDir, PathConv.toInternal(OS.Path.concat(FrameworkDir,FrameworkVersion))))
  | NONE =>
  (* SMLNETPATH if set, otherwise the directory the compiler was loaded from *)
  case (case OS.Process.getEnv RuntimeNames.compilerDir of
          NONE => heapCompilerDir ()
        | dir => dir) of
    NONE =>
    failWith ("Cannot determine the SML.NET directory; set " ^ RuntimeNames.compilerDir)

  | SOME dir =>
    (
      trySet (compilerDir, PathConv.toInternal dir) andalso
      trySet (compilerBinDir, OS.Path.concat(!compilerDir, "bin")) andalso
      (* FrameworkDir and FrameworkVersion if set, otherwise bin/ref *)
      let
        val (dir,version) =
          case (OS.Process.getEnv RuntimeNames.frameworkDir,
                OS.Process.getEnv RuntimeNames.frameworkVersion) of
            (SOME dir,SOME version) => (PathConv.toInternal dir,version)
          | _ => (OS.Path.concat(!compilerBinDir,"ref"),defaultFrameworkVersion)
      in
        runtimeVersion := version;
        frameworkVersion := version;
        trySet(runtimeSysDir,OS.Path.concat(dir,version))
      end
   )
   

(* The ilasm in bin/tools supports linespans *)
  fun setupIlasm() =
    let
	val filename1 = OS.Path.joinDirFile { dir = toolsDir(), file=RuntimeNames.assemCommand }
        val filename2 = OS.Path.joinDirFile { dir = toolsDir(), file=RuntimeNames.assemCommand^".exe"}
    in
      compilerIlasm := true;
      trySet (ilasmFileName, if OS.FileSys.access(filename2, []) then filename2 else filename1)
  end

  fun setupPeverify() =
  let
    val filename = OS.Path.joinDirFile { dir = toolsDir(), file=RuntimeNames.verifyCommand^".dll"}
  in
    if OS.FileSys.access(filename,[])
    then peverifyFileName := SOME filename
    else peverifyFileName := NONE;
    true
  end

fun setupToolsInfo() =
  let 
      val toolDir = OS.Path.joinDirFile{dir= !compilerBinDir,file= !frameworkVersion}
      val _ = if OS.FileSys.access(toolDir,[]) andalso OS.FileSys.isDir(toolDir) then () else OS.FileSys.mkDir(toolDir)
  in  
  trySet(compilerToolDir,toolDir) andalso
  trySet(getmetaFileName, 
         OS.Path.joinDirFile { dir = toolsDir(), file = "getmeta.dll"}) andalso
  trySet(clslistFileName,
         OS.Path.joinDirFile { dir = toolsDir(), file = "clslist.dll"})
  end handle _ => (PrintManager.println ("Could no set up tools info\n");false)

fun setup arg = setupRuntimeInfo arg andalso setupToolsInfo() andalso setupPeverify() andalso setupIlasm() andalso (setupWasRun := true; true)


fun getSysDir() = tryGet runtimeSysDir
fun getCompilerDir() = tryGet compilerDir
fun getCompilerBinDir() = tryGet compilerBinDir
fun getCompilerToolDir() = tryGet compilerToolDir
fun getIlasmFileName() = tryGet ilasmFileName
fun getPeverifyFileName() = tryGet peverifyFileName
fun getClslistFileName() = tryGet clslistFileName
fun getGetmetaFileName() = tryGet getmetaFileName
fun getVersion() = tryGet runtimeVersion
fun getCompilerIlasm() = tryGet compilerIlasm

fun writeRuntimeConfig exe =
  writeFile(OS.Path.joinBaseExt { base = #base (OS.Path.splitBaseExt exe), ext = SOME "runtimeconfig.json" },
            "{\n\
            \  \"runtimeOptions\": {\n\
            \    \"tfm\": \"" ^ runtimeTfm ^ "\",\n\
            \    \"rollForward\": \"Major\",\n\
            \    \"framework\": {\n\
            \      \"name\": \"Microsoft.NETCore.App\",\n\
            \      \"version\": \"" ^ runtimeFrameworkVersion ^ "\"\n\
            \    }\n\
            \  }\n\
            \}\n")

end



