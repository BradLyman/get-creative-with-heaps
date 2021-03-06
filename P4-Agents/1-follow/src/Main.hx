import hxd.Res;
import h2d.Interactive;
import support.h2d.ui.NamedSlider;
import support.h2d.ui.BasicControls;
import support.h2d.Plot;

using support.turtle.VecTurtle;

class Main extends hxd.App {
  var plot:Plot;
  var plotInteractive:Interactive;

  var nodes:Array<Node> = [];
  var cp:BasicControls;
  var force:NamedSlider;

  override function init() {
    plot = new Plot(s2d);
    plot.turtle.lineWidth = 2;
    plot.xAxis = Node.X_BOUND;
    plot.yAxis = Node.Y_BOUND;
    plotInteractive = new Interactive(1, 1, plot);
    plotInteractive.onClick = (_) -> addNode();

    cp = new BasicControls(s2d, Res.fonts.NotoSans32.toFont());
    force = cp.addSlider("attraction", -300, 300);
    force.value = 100;

    new support.h2d.FullscreenButton(s2d);

    onResize();
  }

  function addNode() {
    final n = new Node();
    n.pos = plot.mousePos() + [0.1, 0.1];
    nodes.push(n);
  }

  override function onResize() {
    final size = Math.min(s2d.width, s2d.height);
    plot.resize(size, size);
    plotInteractive.width = plotInteractive.height = size;
    plot.x = (s2d.width - size) / 2;
    plot.y = (s2d.height - size) / 2;
  }

  override function update(dt:Float) {
    if (!cp.visible)
      stepAgents(dt);

    plot.clear();
    for (node in nodes) {
      node.draw(plot.turtle, 4);
    }
  }

  private function stepAgents(dt:Float) {
    final mouse = plot.mousePos();
    for (node in nodes) {
      node.seek(mouse, force.value, 100);
      node.bounds();
      node.integrate(dt);
    }
  }

  static function main() {
    Res.initEmbed();
    new Main();
  }
}
