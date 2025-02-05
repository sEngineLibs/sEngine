package s2d.ui.elements.positioning;

import kha.Canvas;
// s2d
import s2d.ui.positioning.Alignment;

class Row extends UIElement {
	public var spacing:Float = 0.0;

	override function render(target:Canvas) {
		final g2 = target.g2;

		g2.transformation = finalModel;
		#if (S2D_UI_DEBUG_ELEMENT_BOUNDS == 1)
		g2.color = White;
		g2.opacity = 0.75;
		g2.drawRect(x, y, width, height, 2.0);
		#end
		g2.opacity = finalOpacity;
		var _x = x + left.padding;
		var _y = y + top.padding;
		for (child in children) {
			if (child.visible) {
				var _yo = child.layout.topMargin;
				if (child.layout.alignment & Alignment.VCenter != 0)
					_yo = (height - child.height) / 2;
				else if (child.layout.alignment & Alignment.Bottom != 0)
					_yo = height - child.height;
				child.setPosition(_x + child.layout.leftMargin, _y + _yo);
				child.render(target);
				_x += child.width + spacing;
			}
		}
	}
}
