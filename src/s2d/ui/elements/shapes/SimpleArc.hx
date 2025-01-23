package sui.elements.shapes;

import kha.Canvas;
// sui
import sui.effects.Border;

using score.graphics.GraphicsExtension;

@:structInit
class SimpleArc extends SimpleDrawableElement {
	public var border:Border = {};
	public var radius:Float = 0;
	public var sAngle:Float = 90;
	public var eAngle:Float = 0;
	public var clockwise:Bool = false;
	public var segments:Int = 16;

	override function simpleDraw(target:Canvas) {
		var x = left.position;
		var y = top.position;

		target.g2.color = color;
		target.g2.fillArc(x, y, radius, sAngle, eAngle, !clockwise, segments);
		target.g2.color = border.color;
		target.g2.drawArc(x, y, radius, sAngle, eAngle, border.width, !clockwise, segments);
	}
}
