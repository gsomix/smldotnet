#!/usr/bin/env -S dotnet fsi
// Build SML.NET: dotnet fsi build.fsx [target...]
//
// Targets:
//   tools     .NET tools and reference assemblies (bin/tools, bin/ref)
//   compiler  compiler heap image bin/smlnet.<arch>-<os> (SML/NJ 110.99.9,
//             ml-build and ml-lex on the PATH)
//   all       tools and compiler (default)
//   help      show this message

open System
open System.Diagnostics

let root = __SOURCE_DIRECTORY__

let run (program: string) (args: string[]) =
    let command = String.concat " " [| program; yield! args |]
    printfn $"> {command}"

    let psi = ProcessStartInfo(program, args, WorkingDirectory = root, UseShellExecute = false)
    use p = Process.Start psi
    p.WaitForExit()
    if p.ExitCode <> 0 then
        failwith $"{program} failed with exit code {p.ExitCode}"

let tools () =
    run "dotnet" [| "build"; "src/clr/tools/tools.slnx"; "-c"; "Release" |]

let compiler () =
    let mlBuild = if OperatingSystem.IsWindows() then "ml-build.bat" else "ml-build"
    run mlBuild [| "src/sources.cm"; "TopLevel.entry"; "bin/smlnet" |]

let usage () =
    printfn "Usage: dotnet fsi build.fsx [tools|compiler|all|help]..."

let targets =
    dict [|
        "tools", tools
        "compiler", compiler
        "all", (fun () -> tools (); compiler ())
        "help", usage
    |]

let requestedTargets =
    match fsi.CommandLineArgs[1..] with
    | [||] -> [| "all" |]
    | targets -> targets

match requestedTargets |> Array.tryFind (targets.ContainsKey >> not) with
| Some target ->
    eprintfn $"Unknown target: {target}"
    usage ()
    exit 1
| None ->
    try
        for t in requestedTargets do
            targets[t] ()
    with e ->
        eprintfn $"Error: {e.Message}"
        exit 1
