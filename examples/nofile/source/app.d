module app;

import nofile;

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
