import std.file;
import std.variant;
import std.path;
import std.stdio;
import dlangui;
import std.algorithm;
import std.range;


import tm = treemap;
import std.datetime;
import treemapwidget;

class Node {
  string name;
  double size;
  Node[] childs;
  this(string name, double size) {
    this.name = name;
    this.size = size;
  }
  this(string name, Node[] childs) {
    this(name, childs.map!(v => v.size).sum);
    this.childs = childs;
  }
  override string toString() {
    return "Node { size: " ~ size.to!string ~ " }";
  }
}

auto doNodeExample(ref TextWidget text) {
  auto childs = [ 6.0, 6.0, 4.0, 3.0, 2.0, 2.0, 1.0 ].map!(v => new Node(v.to!string, v)).array();
  auto n = new Node("parent", childs);
  auto w = new TreeMapWidget!Node("treemap", n);
  w.addTreeMapFocusedListener((Node node) {
      text.text = node.name.to!dstring;
    });
  return w;
}
