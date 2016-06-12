module treemap;

/++
 + The challenge to create a reusable Treemap is how to return the
 + rects for the nodes. From the top of my hear there are the
 + following options:
 + 1. force the client to provide a rect member in the used type.
 + 2. return an associative array from Rect[Node] -> path taken.
 + 3. return a new type that holds the node, the rect and childs of
 +    the type.
 +/
import std.file;
import std.stdio;
import std.format;
import std.conv;
import std.algorithm;
import std.range;
import std.variant;

/++
 + Rect struct used to store the positions of the Nodes in the
 + treemap. The position is always relative to the initial rect.
 +/
struct Rect {
  double x;
  double y;
  double width;
  double height;
  this(double x, double y, double width, double height) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }
  double left() {
    return x;
  }
  double right() {
    return x+width;
  }
  double top() {
    return y;
  }
  double bottom() {
    return y+height;
  }
  bool contains(double x, double y) {
    return x >= this.x && x < right() &&
      y >= this.y && y < bottom();
  }
}

@("Rect.basics")
unittest {
  import unit_threaded;
  auto r = Rect(10, 11, 20, 30);
  r.contains(15, 15).shouldEqual(true);
  r.left.shouldEqual(10);
  r.top.shouldEqual(11);
  r.right.shouldEqual(30);
  r.bottom.shouldEqual(41);
}

template TreeMap(Node) {
  double size(Node[] nodes) {
    return nodes.map!(v => v.size).sum;
  }

  /++
   + A Treemap is a compact two dimensional representation of the
   + "size" of Nodes to each other.
   + Each Node has a size that is used to determine how much space is
   + reserved for this Node when laying the Treemap out on a Rect.
   +/
  class TreeMap {
    Rect[Node] treeMap;
    Node rootNode;
    this(Node root) {
      this.rootNode = root;
    }

    /++
     + Layouts the treemap for a Rect.
     +/
    TreeMap layout(Rect rect) {
      layout(rootNode.childs, rootNode.size, rect);
      return this;
    }

    alias Maybe = Algebraic!(Node, typeof(null));
    /++
     + Find the Node for a position.
     + @return Maybe!Node
     + @see Unittest on how to use it.
     +/
    Maybe findFor(double x, double y) {
      foreach (kv; treeMap.byKeyValue()) {
        auto fileNode = kv.key;
        auto rect = kv.value;
        if (rect.contains(x, y)) {
          Maybe res = fileNode;
          return res;
        }
      }
      Maybe res = null;
      return res;
    }

    /++
     + @param n which rect to return.
     + @return the Rect of the given Node.
     +/
    Rect get(Node n) {
      return treeMap[n];
    }

    private void layout(Node[] childs, double size, Rect rect) {
      Row row = Row(rect, size);
      Node[] rest = childs;
      while (rest.length > 0) {
        Node child = rest.front();
        Row newRow = row.add(child);

        if (newRow.worstAspectRatio > row.worstAspectRatio) {
          layout(rest, rest.size(), row.imprint(treeMap));
          return;
        }

        row = newRow;
        rest.popFront();
      }
      row.imprint(treeMap);
    }

    /++
     + A Row collects childnodes and provides means to layout them.
     + To find the best rectangular treemap layout it also can find
     + the child with the worst aspect ratio. The layouting performed in
     + TreeMap is a two step process:
     + - first the best row to fill the area is searched (this is done
     +   incrementally child Node by child Node.
     + - second the found Row is imprinted (which means the layout
     +   coordinates are added to the child Nodes).
     +/
    private struct Row {
      /// the total area that the row could take
      Rect rect;
      /// the total size that corresponds to the total area
      double size;

      double fixedLength;
      double variableLength;

      Node[] childs;
      double worstAspectRatio;
      double area;

      public this(Rect rect, double size) {
        this.rect = rect;
        this.size = size;
        this.fixedLength = min(rect.width, rect.height);
        this.variableLength = 0;
        this.worstAspectRatio = double.max;
        this.area = 0;
      }

      private static double aspectRatio(double size, double sharedLength, double l2) {
        double l1 = sharedLength * size;
        return max(l1/l2, l2/l1);
      }

      public this(Rect rect, Node[] childs, double size) {
        this(rect, size);
        this.childs = childs;
        double sizeOfAllChilds = childs.size();
        double percentageOfTotalArea = sizeOfAllChilds / size;
        this.variableLength = max(rect.width, rect.height) * percentageOfTotalArea;
        double height = min(rect.width, rect.height);
        this.worstAspectRatio = childs.map!(n => aspectRatio(n.size, height / sizeOfAllChilds, variableLength)).reduce!max;
      }

      public Row add(Node n) {
        Node[] tmp = childs ~ n;
        return Row(rect, childs~n, size);
      }

      public Rect imprint(ref Rect[Node] treemap) {
        if (rect.height < rect.width) {
          return imprintLeft(treemap);
        } else {
          return imprintTop(treemap);
        }
      }

      private Rect imprintLeft(ref Rect[Node] treemap) {
        double offset = 0;
        foreach (child; childs) {
          double percentage = child.size / childs.size();
          double height = percentage * rect.height;
          treemap[child] = Rect(rect.x, rect.y+offset, variableLength, height);
          offset += height;
        }
        return Rect(rect.x+variableLength, rect.y, rect.width-variableLength, rect.height);
      }

      private Rect imprintTop(ref Rect[Node] treemap) {
        double offset = 0;
        foreach(child; childs) {
          double percentage = child.size / childs.size();
          double width = percentage * rect.width;
          treemap[child] = Rect(rect.x+offset, rect.y+0, width, variableLength);
          offset += width;
        }
        return Rect(rect.x, rect.y+variableLength, rect.width, rect.height-variableLength);
      }
    }
  }
}

@("Treemap")
unittest {
  class Node {
    double size;
    Node[] childs;
    this(double size) {
      this.size = size;
    }
    this(Node[] childs) {
      this.childs = childs;
      this.size = childs.map!(v => v.size).sum;
    }
  }

  import std.math : approxEqual;
  import std.algorithm : equal;
  import unit_threaded;

  void shouldEqual2(Rect r1, Rect r2) {
    r1.x.shouldEqual(r2.x);
    r1.y.shouldEqual(r2.y);
    r1.width.shouldEqual(r2.width);
    r1.height.shouldEqual(r2.height);
  }

  auto childs = [ 6, 6, 4, 3, 2, 2, 1 ].map!(v => new Node(v)).array;
  auto n = new Node(childs);
  auto res = new TreeMap!(Node)(n).layout(Rect(0, 0, 600, 400));
  void check(int idx, Rect r) {
    shouldEqual2(res.get(childs[idx]), r);
  }
  check(0, Rect(0, 0, 300, 200));
  check(1, Rect(0, 200, 300, 200));

  check(2, Rect(300, 0, 171, 233));
  check(3, Rect(471, 0, 129, 233));

  check(4, Rect(300, 233, 120, 166));
  check(5, Rect(420, 233, 120, 166));
  check(6, Rect(540, 233, 60, 166));

  auto found = res.findFor(1, 1);
  found.tryVisit!(
    (Node n) {},
    () {assert(false);}
  )();
  auto notFound = res.findFor(-1, -1);
  notFound.tryVisit!(
    (typeof(null) n) {},
    () {assert(false);}
  )();
}
