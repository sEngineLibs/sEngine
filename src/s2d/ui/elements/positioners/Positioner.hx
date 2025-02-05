package s2d.ui.elements.positioners;

import kha.Canvas;
// s2d
import s2d.math.Vec4;

abstract class Positioner extends UIElement {
	var prevRect:Vec4;

	abstract function position(element:UIElement):Vec4;

	override function render(target:Canvas) {
		final g2 = target.g2;

		g2.transformation = finalModel;
		#if (S2D_UI_DEBUG_ELEMENT_BOUNDS == 1)
		g2.color = White;
		g2.opacity = 0.75;
		g2.drawRect(x, y, width, height, 2.0);
		#end
		g2.opacity = finalOpacity;

		prevRect = new Vec4(0.0, 0.0, 0.0, 0.0);
		for (child in children) {
			if (child.visible) {
				prevRect = position(child);
				child.render(target);
			}
		}
	}
}
