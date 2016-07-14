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

  Node lastSelected;
  MouseEvent lastMouseEvent;

  Node[] lastNodes ;

  void up() {
    if ((lastNodes != null) && (lastNodes.length >= 1)) {
      auto node = lastNodes[$-1];
      lastNodes = lastNodes[0..$-1];
      treeMap = new tm.TreeMap!Node(node);
      treeMap.layout(tm.Rect(0, 0, pos.width, pos.height));
      invalidate();
    }
  }

  this(string id, Node rootNode) {
    super(id);
    this.treeMap = new tm.TreeMap!Node(rootNode);
    clickable = true;
    focusable = true;

    click.connect(
      delegate(Widget w) {
        auto r = treeMap.findFor(lastMouseEvent.pos.x, lastMouseEvent.pos.y);
        r.tryVisit!(
          (Node node) {
            if (node.childs != null) {
              lastNodes ~= treeMap.rootNode;
              treeMap = new tm.TreeMap!Node(node);
              treeMap.layout(tm.Rect(0, 0, w.pos.width, w.pos.height));
              invalidate();
            } else {
            }
          },
          () {});
        return true;
      }
    );

    keyEvent.connect(
      delegate(Widget source, KeyEvent event) {
        if ((event.keyCode == 8) && (event.action == KeyAction.KeyUp)) {
          up();
          return true;
        }
        return false;
      }
    );

    mouseEvent.connect(
      delegate(Widget w, MouseEvent me) {
        lastMouseEvent = me;
        auto r = treeMap.findFor(me.pos.x, me.pos.y);
        Node selected;
        r.tryVisit!(
          (Node node) { selected = node; },
          () {}
        )();

        if (selected != lastSelected) {
          lastSelected = selected;
          onTreeMapFocused(selected);
          return true;
        }
        return false;
      });
  }

  public Signal!OnTreeMapHandler onTreeMapFocused;
  public auto addTreeMapFocusedListener(void delegate (Node) listener) {
    onTreeMapFocused.connect(listener);
    return this;
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

    drawNode(treeMap.rootNode, buf);
  }
  private void drawNode(Node n, DrawBuf buf) {
    auto r = treeMap.get(n);
    writeln("found ", r, " for ", n);
    if (r) {
      buf.drawFrame((*r).toUiRect(), 0xff00ff, Rect(1, 1, 1, 1), 0xa0a0a0);
      foreach (child; n.childs) {
        drawNode(child, buf);
      }
    }
  }
}
