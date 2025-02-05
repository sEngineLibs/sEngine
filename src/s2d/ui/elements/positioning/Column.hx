package s2d.ui.elements.positioning;

import kha.Canvas;
// s2d
import s2d.ui.positioning.Alignment;

class Column extends UIElement {
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
				var _xo = child.layout.leftMargin;
				if (child.layout.alignment & Alignment.HCenter != 0)
					_xo = (width - child.width) / 2;
				else if (child.layout.alignment & Alignment.Right != 0)
					_xo = width - child.width;
				child.setPosition(_x + _xo, _y + child.layout.topMargin);
				child.render(target);
				_y += child.height + spacing;
			}
		}
	}
}
