module app;

import std.file;
import std.path;
import std.stdio;
import std.algorithm;
import std.range;
import std.datetime;
import dlangui;
import std.variant;
import std.experimental.logger;

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
  alias FileTreeMap = TreeMapWidget!FileNode;
  auto w = new FileTreeMap("filemap", fileNode, 4);
  w.addTreeMapFocusedListener((FileTreeMap.Maybe maybeNode) {
      maybeNode.visit!(
        (FileNode node) {
          log("focused on ", node);
          text.text = node.getName().to!dstring ~ " (" ~ node.weight.humanize.to!dstring ~ "Byte)";
        },
        (typeof(null)) {
          log("focused on nothing");
          text.text = "null";
        }
      )();
    });
  return w;
}

import dlangui.dml.parser;

extern (C) int UIAppMain(string[] args) {
  auto window = Platform.instance.createWindow(to!dstring("treemap"), null);

  auto vl = parseML!VerticalLayout(q{VerticalLayout{layoutWidth: fill; layoutHeight: fill;}});

  auto text = new TextWidget("label", "no selection".to!dstring);
  text.fontSize(32);

  auto w = doFileExample(args, text);
  w.backgroundColor(0x000000).layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT).padding(Rect(10, 10, 10, 10));

  vl.addChild(w);
  vl.addChild(text);

  window.mainWidget = vl;
  window.show();
  return Platform.instance.enterMessageLoop();
}

