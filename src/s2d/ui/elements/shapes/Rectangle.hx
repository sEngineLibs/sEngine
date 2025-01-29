package s2d.ui.elements.shapes;

import kha.Canvas;
// s2d
import s2d.ui.graphics.Drawers;

class Rectangle extends UIElement {
	public var radius:Float;
	public var softness:Float;

	public function new(?radius:Float = 0.0, ?softness:Float = 1.0, ?scene:UIScene) {
		super(scene);
		this.radius = radius;
		this.softness = softness;
	}

	override function draw(target:Canvas) @:privateAccess {
		Drawers.rectDrawer.render(target, this);
	}
}
