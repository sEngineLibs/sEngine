package s2d.elements.shapes;

import se.Texture;

class Rectangle extends UISceneElement {
	public function new(?parent:Element) {
		super(parent);
	}

	override inline function draw(target:Texture) {
		target.ctx2D.fillRect(x, y, width, height);
	}
}
