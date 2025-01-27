package s2d.ui;

import kha.Canvas;
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
	}
}
