module app;

import std.file;
import std.variant;
import std.path;
import std.stdio;
import std.algorithm;
import std.range;
import std.datetime;
import dlangui;

mixin APP_ENTRY_POINT;

import std.datetime;
import treemapwidget;
import filenode;

auto doFileExample(string[] args, ref TextWidget text) {
  auto path = args.length == 2 ? args[1] : ".";
  StopWatch sw;
  sw.start();
  auto fileNode = calcFileNode(DirEntry(path.asAbsolutePath.asNormalizedPath.to!string));
  sw.stop();
  writeln("getting file infos took: ", sw.peek().msecs, "ms");
  auto w = new TreeMapWidget!FileNode("filemap", fileNode);
  w.addTreeMapFocusedListener((FileNode node) {
      text.text = node.getName().to!dstring ~ " (" ~ node.size.humanize.to!dstring ~ "Byte)";
    });
  return w;
}

extern (C) int UIAppMain(string[] args) {
  auto window = Platform.instance.createWindow(to!dstring("treemap"), null);

  auto vl = new VerticalLayout("vl");
  vl.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

  auto text = new TextWidget("label", "no selection".to!dstring);
  text.fontSize(32);

  //auto w = doNodeExample(text);
  auto w = doFileExample(args, text);

  vl.addChild(w);
  vl.addChild(text);
  w.backgroundColor(0x000000).layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT).padding(Rect(10, 10, 10, 10));

  window.mainWidget = vl;
  window.show();
  return Platform.instance.enterMessageLoop();
}

