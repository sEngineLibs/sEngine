package s2d.elements.shapes;

import se.Texture;

class Rectangle extends DrawableElement {
	public function new(?parent:Element) {
		super(parent);
	}

	function draw(target:Texture) {
		target.ctx2D.fillRect(left, top, width, height);
	}
}
