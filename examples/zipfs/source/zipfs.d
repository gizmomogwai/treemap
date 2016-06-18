
module zipfs;

import std.zip;
import std.file;
import std.variant;
import std.path;
import std.stdio;
import std.algorithm;
import std.range;
import std.datetime;

import std.datetime;
//import unit_threaded;
import std.conv;

string[] parentDirs(string pathname) {
  return pathname.split("/")[0..$-1];
}
/+
unittest {
  "abc/".parentDirs.shouldEqual(["abc"]);
}
+/
string file(string pathname) {
  auto res = pathname.split("/")[$-1];
  if (res == "") {
    return null;
  }
  return res;
}
/+
unittest {
  "abc/".file.shouldEqual(null);
  "abc/def".file.shouldEqual("def");
}
+/
class ZipFile {
  string name;
  ArchiveMember member;
  ZipFile[string] children;
  size_t size;
  this(string name, ArchiveMember member) {
    this(name);
    this.member = member;
  }
  this(string name) {
    this.name = name;
  }
  ZipFile[] childs() {
    return children.byValue().array;
  }
  string getName() {
    return name;
  }
  bool isDirectory() {
    return member is null || member.fileAttributes.attrIsDir;
  }
  static ZipFile create(ZipArchive archive) {
    ZipFile res = new ZipFile("ZipArchive");
    foreach (member; archive.directory.byValue()) {
      res.add(member);
    }
    res.calcSize();
    return res;
  }
  private void calcSize() {
    if (children !is null) {
      foreach (child; childs) {
        child.calcSize();
      }
      size = childs.map!(v => v.size).sum;
    } else {
      assert(member);
      size = member.expandedSize;
    }
  }
  void add(ArchiveMember member) {
    auto dirs = parentDirs(member.name);
    auto h = this;
    foreach (dir; dirs) {
      if (!(dir in h.children)) {
        h.children[dir] = new ZipFile(dir);
      }
      h = h.children[dir];
    }
    auto file = file(member.name);
    if (file != null) {
      h.children[file] = new ZipFile(file, member);
    }
  }
  override string toString() {
    return toString("");
  }
  string toString(string prefix) {
    auto res = prefix ~ (member !is null ? member.name : name) ~ " (" ~ size.to!string ~ ")\n";
    foreach (child; childs) {
      res ~= child.toString(prefix ~ "  ");
    }
    return res;
  }
}
/+
unittest {
  auto zip = new ZipArchive(read("test.zip"));
  auto zf = ZipFile.create(zip);
  writelnUt("1234");
  writelnUt("\n" ~ zf.toString());
  /*
  writelnUt("Archive: test.zip");
  writelnUt("%-10s  %-8s  Name", "Length", "CRC-32");
  foreach (key, v; zip.directory) {
    writelnUt(key);
  }
  zip.directory.length.shouldEqual(17);
  auto r = zip.directory.byKey();
  auto f1 = r.front; r.popFront;
  f1.shouldEqual("source/zipped/package.d~");
  zip.directory[f1].fileAttributes.attrIsDir.shouldEqual(false);
  auto f2 = r.front;
  f2.shouldEqual(".dub/");
  zip.directory[f2].fileAttributes.attrIsDir.shouldEqual(true);
  */
}

+/