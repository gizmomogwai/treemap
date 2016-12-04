module app;

import std.file;
import std.path;
import std.stdio;
import std.algorithm;
import std.range;
import std.datetime;
import dlangui;
import std.variant;

mixin APP_ENTRY_POINT;

import std.datetime;
import treemapwidget;
import zipfs;
import std.zip;

auto doZipExample(string[] args, ref TextWidget text) {
  auto path = args.length == 2 ? args[1] : ".";
  StopWatch sw;
  sw.start();
  auto zipArchive = new ZipArchive(read(path));
  auto zip = ZipFile.create(zipArchive);
  foreach (child; zip.childs) {
    writeln("on root directory of zip: ", child);
  }
  sw.stop();
  writeln("getting file infos took: ", sw.peek().msecs, "ms");
  alias ZipFileTreeMap = TreeMapWidget!ZipFile;
  auto w = new ZipFileTreeMap("zipmap", zip);
  w.addTreeMapFocusedListener((ZipFileTreeMap.Maybe maybe) {
      maybe.visit!((ZipFile node) {
          text.text = node.getName().to!dstring ~ " (" ~ node.weight.humanize.to!dstring ~ "Byte)";
        },
        (typeof(null)) {
          text.text = "no selection";
        }
      )();
    });
  return w;
}

extern (C) int UIAppMain(string[] args) {
  auto window = Platform.instance.createWindow(to!dstring("treemap"), null);

  auto vl = new VerticalLayout("vl");
  vl.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

  auto text = new TextWidget("label", "no selection".to!dstring);
  text.fontSize(32);

  auto w = doZipExample(args, text);

  vl.addChild(w);
  vl.addChild(text);
  w.backgroundColor(0x000000).layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT).padding(Rect(10, 10, 10, 10));

  window.mainWidget = vl;
  window.show();
  return Platform.instance.enterMessageLoop();
}
