package s2d.ui;

import kha.Canvas;
import kha.math.FastMatrix3;
// s2d.ui
import s2d.app.App;
import s2d.app.input.Mouse;
import s2d.ui.elements.UIElement;

@:structInit
@:allow(s2d.S2D)
@:allow(s2d.ui.elements.UIElement)
class UIScene {
	var elements:Array<UIElement> = [];
	var prefocused:UIElement;

	function new() {
		App.input.mouse.notifyOnMoved((x, y, dx, dy) -> {
			if (prefocused != null)
				prefocused.prefocused = false;
			prefocused = elementAt(x, y);
			if (prefocused != null)
				prefocused.prefocused = true;
			trace(prefocused);
		});
		App.input.mouse.notifyOnButtonDown(MouseButton.Left, (x, y) -> {
			if (prefocused != null)
				prefocused.focused = true;
		});
	}

	function addBaseElement(element:UIElement) {
		elements.push(element);
	}

	function removeBaseElement(element:UIElement) {
		elements.remove(element);
	}

	public function elementAt(x:Float, y:Float):UIElement {
		var c:UIElement = null;
		for (i in 1...elements.length + 1) {
			final element = elements[elements.length - i];
			final e = element.childAt(x, y);

			if (e != null) {
				c = e;
				break;
			} else if (element.isOverlapping(x, y)) {
				c = element;
				break;
			}
		}
		return c;
	}

	function render(target:Canvas) {
		final g2 = target.g2;

		g2.begin(false);
		for (element in elements)
			element.render(target);
		g2.color = White;
		g2.opacity = 1.0;
		g2.transformation = FastMatrix3.identity();
		g2.end();
	}
}
