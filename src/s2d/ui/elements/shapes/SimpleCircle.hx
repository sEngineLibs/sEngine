package sui.elements.shapes;

import kha.Canvas;
// sui
import sui.effects.Border;

using score.graphics.GraphicsExtension;

class SimpleCircle extends SimpleDrawableElement {
	public var border:Border = {};
	public var radius:Float = 0;
	public var segments:Int = 64;

	override inline function simpleDraw(target:Canvas) {
		var x = left.position;
		var y = top.position;

		target.g2.color = color;
		target.g2.fillCircle(x, y, radius, segments);
		target.g2.color = border.color;
		target.g2.drawCircle(x, y, radius, border.width, segments);
	}
}
