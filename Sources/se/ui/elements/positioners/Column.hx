package se.ui.elements.positioners;

import se.math.VectorMath;
import se.ui.Alignment;

class Column extends Positioner {
	public var spacing:Float = 0.0;

	function position(element:UIElement):Vec4 {
		var _x = x + left.padding;
		var _y = y + top.padding + prevRect.w + spacing;

		var _xo = element.layout.leftMargin;
		if (element.layout.alignment & Alignment.HCenter != 0)
			_xo = (width - element.width) / 2;
		else if (element.layout.alignment & Alignment.Right != 0)
			_xo = width - element.width;
		element.setPosition(_x + _xo, _y + element.layout.topMargin);

		return new Vec4(element.x, element.y, element.width, element.height);
	}
}
