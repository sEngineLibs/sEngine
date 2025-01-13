package sui.elements.shapes;

import kha.Canvas;
import kha.math.Vector2;

@:structInit
class SimpleLine extends SimpleDrawableElement {
	public var lineWidth:Float = 1;
	public var start:Vector2 = {x: 0, y: 0}
	public var end:Vector2 = {x: 0, y: 0}

	override inline function simpleDraw(target:Canvas) {
		var x = left.position;
		var y = right.position;

		target.g2.color = color;
		target.g2.drawLine(x + start.x, y + start.y, x + end.x, y + end.y, lineWidth);
	}
}
