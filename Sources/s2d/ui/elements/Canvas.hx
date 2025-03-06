package s2d.ui.elements;

import se.Texture;

class Canvas extends UISceneElement {
	@:signal function paint(target:Texture):Void;

	override inline function draw(target:Texture) {
		target.ctx2D.transform.global.translate(x, y);
		paint(target);
		target.ctx2D.transform.global.translate(-x, -y);
	}
}
