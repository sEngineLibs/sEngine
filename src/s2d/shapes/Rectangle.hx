package s2d.shapes;

import se.Texture;

class Rectangle extends DrawableElement {
	function draw(target:Texture) {
		target.ctx2D.fillRect(absX, absY, width, height);
	}
}
