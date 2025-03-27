package s2d.elements.shapes;

import se.Texture;

class Rectangle extends DrawableElement {
	public function new() {
		super();
	}

	function draw(target:Texture) {
		target.ctx2D.fillRect(absX, absY, width, height);
	}
}
