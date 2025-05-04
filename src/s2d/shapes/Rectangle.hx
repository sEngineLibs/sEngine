package s2d.shapes;

import se.Texture;

class Rectangle extends DrawableElement {
	public function new(name:String = "rectangle") {
		super(name);
	}

	function draw(target:Texture) {
		target.ctx2D.fillRect(absX, absY, width, height);
	}
}
