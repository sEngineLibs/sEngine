package s2d.elements;

import se.Texture;
import se.math.Mat3;

class Canvas extends UISceneElement {
	@:signal function paint(target:Texture):Void;

	override inline function draw(target:Texture) {
		target.ctx2D.transform *= Mat3.translation(x, y);
		paint(target);
		target.ctx2D.transform *= Mat3.translation(-x, -y);
	}
}
