package s2d.ui.elements.shapes;

import se.Texture;

class Rectangle extends UISceneElement {
	public function new(?parent:UIElement) {
		super(parent);
	}

	override inline function draw(target:Texture) {
		target.context2D.fillRect(x, y, width, height);
	}
}
