package s2d.ui.elements.shapes;

import kha.Canvas;
// s2d
import s2d.ui.graphics.Drawers;

class Rectangle extends UIElement {
	public var softness:Float = 1.0;
	public var radius:Float = 0.0;

	function draw(target:Canvas) @:privateAccess {
		Drawers.rectDrawer.render(target, this);
	}
}
