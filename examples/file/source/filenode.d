module filenode;
import std.array;
import std.file;
import std.stdio;
import std.algorithm;

struct FileNode {
  string name;
  ulong weight;
  FileNode[] children;
  bool invalid;
  this(string name) {
    this.name = name;
    this.invalid = true;
  }
  this(string name, ulong weight) {
    this(name, weight, null);
  }
  this(string name, ulong weight, FileNode[] childs) {
    this.name = name;
    this.weight = weight;
    this.children = childs;
  }
  FileNode[] childs() {
    return children;
  }
  ulong getWeight() {
    return weight;
  }
  string getName() {
    return name;
  }
  string toString() {
    import std.conv;
    return "{ name: \"" ~getName() ~ "\" , weight: " ~ getWeight().to!string ~ " }";
  }
}

FileNode calcFileNode(DirEntry entry) {
  if (entry.isDir) {
    auto childs = dirEntries(entry.name, SpanMode.shallow, false)
      .map!(v => calcFileNode(v))
      .filter!(v => !v.invalid).array()
      .sort!((a, b) => a.getWeight() > b.getWeight()).array();
    auto childSize = 0L.reduce!((sum, v) => sum + v.getWeight)(childs);
    return FileNode(entry, childSize, childs);
  } else {
    try {
      size_t s = DirEntry(entry).size;
      return FileNode(entry, s);
    } catch (Exception e) {
      writeln("problems with file", entry);
      return FileNode(entry);
    }
  }
}

size_t calcSize(DirEntry entry) {
  if (entry.isDir) {
    size_t res = 0;
    foreach (DirEntry e; dirEntries(entry.name, SpanMode.shallow, false)) {
      res += calcSize(e);
    }
    return res;
  } else {
    size_t res = 0;
    try {
      res = entry.size;
    } catch (Exception e) {
    }
    return res;
  }
}

size_t calcSize(string file) {
  return calcSize(DirEntry(file));
}
