module app;

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

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
  auto window = Platform.instance.createWindow(to!dstring("treemap"), null);

  auto vl = new VerticalLayout("vl");
  vl.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

  auto text = new TextWidget("label", "no selection".to!dstring);
  text.fontSize(32);

  auto w = doNodeExample(text);

  vl.addChild(w);
  vl.addChild(text);
  w.backgroundColor(0x000000).layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT).padding(Rect(10, 10, 10, 10));

  window.mainWidget = vl;
  window.show();
  return Platform.instance.enterMessageLoop();
}

