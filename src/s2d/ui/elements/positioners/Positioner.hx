package s2d.ui.elements.positioners;

import kha.Canvas;
// s2d
import s2d.math.Vec4;

abstract class Positioner extends UIElement {
	var prevRect:Vec4;

	abstract function position(element:UIElement):Vec4;

	override function renderTree(target:Canvas) {
		prevRect = new Vec4(0.0, 0.0, 0.0, 0.0);
		for (child in children) {
			if (child.visible) {
				prevRect = position(child);
				child.render(target);
			}
		}
	}
}
