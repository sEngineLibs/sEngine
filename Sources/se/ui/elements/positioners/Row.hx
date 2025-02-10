package se.ui.elements.positioners;

import se.math.VectorMath;
import se.ui.Alignment;

class Row extends Positioner {
	public var spacing:Float = 0.0;

	function position(element:UIElement):Vec4 {
		var _x = x + left.padding + prevRect.z + spacing;
		var _y = y + top.padding;

		var _yo = element.layout.topMargin;
		if (element.layout.alignment & Alignment.VCenter != 0)
			_yo = (height - element.height) / 2;
		else if (element.layout.alignment & Alignment.Bottom != 0)
			_yo = height - element.height;
		element.setPosition(_x + element.layout.leftMargin, _y + _yo);

		return new Vec4(element.x, element.y, element.width, element.height);
	}
}
