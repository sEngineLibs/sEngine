package s2d.elements;

import se.Texture;
import se.math.Mat3;

class Canvas extends InteractiveElement {
	@:signal function paint(target:Texture):Void;

	override inline function draw(target:Texture) {
		super.draw(target);

		target.ctx2D.transform *= Mat3.translation(x, y);
		paint(target);
		target.ctx2D.transform *= Mat3.translation(-x, -y);
	}
}
