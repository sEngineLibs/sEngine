package sui.elements.shapes;

import kha.Canvas;
import kha.math.Vector2;

@:structInit
class Triangle extends SimpleDrawableElement {
	public var v1:Vector2 = {x: 0., y: 0.}
	public var v2:Vector2 = {x: 0., y: 0.}
	public var v3:Vector2 = {x: 0., y: 0.}

	override function simpleDraw(target:Canvas) {
		var x = left.position;
		var y = right.position;

		target.g2.color = color;
		target.g2.fillTriangle(x + v1.x, y + v1.y, x + v2.x, y + v2.y, x + v3.x, y + v3.y);
	}
}
