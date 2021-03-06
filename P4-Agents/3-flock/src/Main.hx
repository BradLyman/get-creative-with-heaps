import hxd.Window;
import support.color.HSL;
import support.turtle.Turtle;
import Node.BruteForce;
import Node.NodeIndex;
import support.linAlg2d.Vec;
import hxd.Res;
import h2d.Interactive;
import support.h2d.Plot;

using support.turtle.VecTurtle;

class Main extends hxd.App {
  var plot:Plot;
  var plotInteractive:Interactive;

  var selected:Node;
  var index:NodeIndex = new BruteForce();

  override function init() {
    plot = new Plot(s2d);
    plot.turtle.lineWidth = 2;
    plot.xAxis = Node.X_BOUND;
    plot.yAxis = Node.Y_BOUND;
    plotInteractive = new Interactive(1, 1, plot);
    plotInteractive.onClick = (_) -> selectNode();

    new support.h2d.FullscreenButton(s2d);

    Window.getInstance().addEventTarget((e:hxd.Event) -> {
      if (e.kind == EKeyDown) {
        addNode();
      }
    });

    onResize();
  }

  function addNode() {
    final n = new Node();
    n.pos = plot.mousePos() + [0.1, 0.1];
    n.vel = Vec.ofPolar(Math.random() * Math.PI * 2, 200);
    index.insert(n);
  }

  function selectNode() {
    selected = null;
    final n = new Node();
    n.pos = plot.mousePos();
    final nearby = index.nearestNeighbors(n, 20);
    if (nearby.length >= 1) {
      selected = nearby[0];
    }
  }

  override function onResize() {
    final size = Math.min(s2d.width, s2d.height);
    plot.resize(size, size);
    plotInteractive.width = plotInteractive.height = size;
    plot.x = (s2d.width - size) / 2;
    plot.y = (s2d.height - size) / 2;
  }

  override function update(dt:Float) {
    plot.clear();
    stepNodes(dt);
    drawNodes();
    integrateNodes(dt);
  }

  private function stepNodes(dt:Float) {
    for (node in index) {
      node.bounds();
      final friends = index.nearestNeighbors(node, 100);
      node.align(friends, 200);
      node.avoid(friends, 500, 20);
      node.seek(center(friends), 100, 20);
    }
  }

  private function center(friends:Array<Node>):Vec {
    var count = 0;
    var center:Vec = [0, 0];
    for (node in friends) {
      count++;
      center.add(node.pos);
    }
    if (count > 0) {
      center *= (1.0 / count);
    }
    return center;
  }

  private function integrateNodes(dt:Float) {
    for (node in index) {
      node.integrate(dt);
    }
  }

  private function drawNodes() {
    plot.turtle.lineWidth = 3;
    for (node in index) {
      node.draw(plot.turtle, 4);
    }
    if (selected != null) {
      drawSelected();
    }
  }

  private function drawSelected() {
    final radius = 100;
    plot.turtle.lineWidth = 2;
    drawCircle(plot.turtle, selected.pos, radius);
    final nearby = index.nearestNeighbors(selected, radius);

    final oldColor = plot.turtle.color;
    plot.turtle.color = new HSL(120, 1, 0.5, 1);
    plot.turtle.lineWidth = 4;
    for (node in nearby) {
      node.draw(plot.turtle, 4.5);
    }

    plot.turtle.color = new HSL(200);
    drawCircle(plot.turtle, center(nearby), 10);

    plot.turtle.color = oldColor;

    selected.drawDebug(plot.turtle);
  }

  private function drawCircle(turtle:Turtle, at:Vec, radius:Float) {
    final segments = 32;
    final start = at + Vec.ofPolar(0, radius);
    turtle.moveToVec(start);
    for (i in 0...segments) {
      final angle = i / segments * Math.PI * 2.0;
      turtle.lineToVec(at + Vec.ofPolar(angle, radius));
    }
    turtle.lineToVec(start);
  }

  static function main() {
    Res.initEmbed();
    new Main();
  }
}
