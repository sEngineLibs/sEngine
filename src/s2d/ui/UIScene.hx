package s2d.ui;

import kha.Canvas;
import kha.math.FastMatrix3;
// s2d.ui
import s2d.ui.elements.UIElement;

@:structInit
class UIScene {
	var elements:Array<UIElement> = [];

	public function new() {}

	public function addBaseElement(element:UIElement) {
		elements.push(element);
	}

	public function removeBaseElement(element:UIElement) {
		elements.remove(element);
	}

	public function render(target:Canvas) {
		for (element in elements)
			element.render(target);
		target.g2.color = White;
		target.g2.opacity = 1.0;
		target.g2.transformation = FastMatrix3.identity();
	}
}
