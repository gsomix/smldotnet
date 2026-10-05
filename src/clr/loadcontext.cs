using System.Reflection;
using System;
using System.Collections.Generic;
using System.IO;

static class LoadContext
{

public static MetadataLoadContext Create(String AssemblyFile, String[] SearchDirs)
{
  String fullName = Path.GetFullPath(AssemblyFile);
  List<String> dirs = new List<String>(SearchDirs);
  dirs.Add(Path.GetDirectoryName(fullName));
  HashSet<String> paths = new HashSet<String>();
  paths.Add(fullName);
  foreach (String dir in dirs)
    if (Directory.Exists(dir))
      foreach (String path in Directory.GetFiles(dir, "*.dll"))
        paths.Add(Path.GetFullPath(path));

  String core = null;
  foreach (String path in paths)
    if (Path.GetFileNameWithoutExtension(path).Equals("netstandard", StringComparison.OrdinalIgnoreCase))
      core = "netstandard";
  return new MetadataLoadContext(new PathAssemblyResolver(paths), core);
}

}
