using System.Reflection;
using System;
using System.IO;

class clslist
{

static String fullName(Type t){
	return t.ToString();
}

static void print(String s)
{
  Console.Out.Write(s);
}

static void print(string field, string s)
{
    print(field);
    print("\n");
    if (s==null) {
	print("null");
    }
    else {
	print(s);
    };
    print("\n");
}

static void print(string field,byte[] b)
{
    print(field);
    print("\n");
    if (b==null) {
	print("null");
    }
    else {
	print("(");
	for (int i = 0; i < b.Length; i++) {
	    print(BitConverter.ToString(b,i,1));
	    print(" ");
	};
	print(")");
    };
    
    print("\n");
}

static void print(string field,Version v)
{
    print(field);
    print("\n");
    if (v == null) {
	print("null");
    }
    else {print(v.Major.ToString());
  	  print(":");
	  print(v.Minor.ToString());
  	  print(":");
	  print(v.Build.ToString());
 	  print(":");                   
	  print(v.Revision.ToString()); 
    };
    print("\n");
}

static bool IsGeneric(Type c)
{
  return (c.IsGenericTypeDefinition);
}

static bool Importable(Type c)
{
  if (!c.IsPublic && !c.IsNestedPublic)
    return false;
  if (IsGeneric(c))
    return false;
  return true;
}

static Type StringType, SingleType, DoubleType;

static int Run(String AssemblyFile,String AssemblyStamp,String[] SearchDirs)
{
  Assembly a = null;

  print("clslist 9\n");
  try { MetadataLoadContext mlc = LoadContext.Create(AssemblyFile, SearchDirs);
        StringType = mlc.CoreAssembly.GetType("System.String");
        SingleType = mlc.CoreAssembly.GetType("System.Single");
        DoubleType = mlc.CoreAssembly.GetType("System.Double");
        a = mlc.LoadFromAssemblyPath(Path.GetFullPath(AssemblyFile));}
  catch (Exception e) { Console.WriteLine("Error: " + e.ToString()); };

  if (a == null) 
  {
    print("ERROR: Assembly ");
    print(AssemblyFile);
    print(" not found\n");
    return -1;
  }
  else
  {
    AssemblyName an = a.GetName();
    print("assemblyFile",AssemblyFile);
    print("stamp",AssemblyStamp);
    print("name",an.Name);
    print("publickeytoken",an.GetPublicKeyToken());
    print("version",an.Version);
   
    Type[] cs = a.GetTypes();
    for (int i = 0; i < cs.Length; i++)
    {
      
      if (Importable(cs[i]))
      {
      print(fullName(cs[i]));
      print(" ");
      if (cs[i].GetConstructors().Length == 0 || cs[i].IsAbstract || cs[i].IsInterface) 
        print(".");
      else
        print("C");
      if (cs[i] == StringType || cs[i].IsEnum || (cs[i].IsPrimitive && cs[i] != SingleType && cs[i] != DoubleType))
        print("=");
      else
        print(".");
      if (cs[i].IsEnum) 
        print("E");
      else
        print(".");
      if (cs[i].IsValueType) 
        print("V");
      else
        print(".");
      print("\n");
      }
    }
    return 0;
  }
}

static void Usage()
{
  print("Usage: clslist AssemblyFile AssemblyStamp [SearchDir ...] out \n\n");
}

public static int Main(String[] a)
{
  String[] args = System.Environment.GetCommandLineArgs();  
  if (args.Length < 4){Usage();return -1;};
  String AssemblyFile = args[1];
  String AssemblyStamp = args[2];
  String[] SearchDirs = new String[args.Length - 4];
  Array.Copy(args, 3, SearchDirs, 0, SearchDirs.Length);
  try { TextWriter tmp = Console.Out;
	FileStream fs1 = new FileStream(args[args.Length - 1], FileMode.Create);
	StreamWriter sw1 = new StreamWriter(fs1);
	Console.SetOut(sw1);	
	int result = Run(AssemblyFile,AssemblyStamp,SearchDirs);
	sw1.Close();
	Console.SetOut(tmp);
	return result; }
  catch {return -1;}
}

}
