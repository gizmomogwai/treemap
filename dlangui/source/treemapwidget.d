module treemapwidget;

import tm = treemap;
import std.file;
import std.variant;
import std.path;
import std.stdio;
import std.algorithm;
import std.range;
import dlangui;
import std.datetime;

Rect toUiRect(tm.Rect r) {
  return Rect(cast(int)r.left(),
              cast(int)r.top(),
              cast(int)r.right(),
              cast(int)r.bottom());
}

string humanize(ulong v) {
  auto units = ["", "k", "m", "g"];
  int idx = 0;
  while (v / 1024 > 0) {
    idx++;
    v /= 1024;
  }
  return v.to!string ~ units[idx];
}

class TreeMapWidget(Node) : Widget {
  interface OnTreeMapHandler {
    void onTreeMap(Node node);
  }

  tm.TreeMap!Node treeMap;

  this(string id, Node rootNode) {
    super(id);
    this.treeMap = new tm.TreeMap!Node(rootNode);
  }

  public Signal!OnTreeMapHandler onTreeMapFocused;
  public auto addTreeMapFocusedListener(void delegate (Node) listener) {
    onTreeMapFocused.connect(listener);
    return this;
  }

  override bool onMouseEvent(MouseEvent me) {
    auto r = treeMap.findFor(me.pos.x, me.pos.y);
    r.tryVisit!(
      (Node node) { onTreeMapFocused(node); },
      () {},
    )();
    return true;
  }

  override void layout(Rect r) {
    StopWatch sw;
    sw.start();
    treeMap.layout(tm.Rect(0, 0, r.width, r.height));
    sw.stop();
    super.layout(r);
  }

  override void onDraw(DrawBuf buf) {
    super.onDraw(buf);
    if (visibility != Visibility.Visible) {
      return;
    }

    auto rc = _pos;
    auto saver = ClipRectSaver(buf, rc);

    auto font = FontManager.instance.getFont(25, FontWeight.Normal, false, FontFamily.SansSerif, "Arial");

    foreach(child; treeMap.rootNode.childs) {
      buf.drawFrame(treeMap.get(child).toUiRect(), 0xff00ff, Rect(1, 1, 1, 1), 0xa0a0a0);
    }
  }
}
