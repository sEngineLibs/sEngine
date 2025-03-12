package s2d.elements.shapes;

import se.Texture;

class Rectangle extends Element {
	public function new(?parent:Element) {
		super(parent);
	}

	override inline function draw(target:Texture) {
		super.draw(target);

		target.ctx2D.fillRect(x, y, width, height);
	}
}
