package s2d.elements.positioners;

import s2d.Alignment;

class Row extends Positioner {
	function position(element:Element) {
		var _x = prevBounds.right + spacing;

		var _yo = element.layout.topMargin;
		if (element.layout.alignment & Alignment.VCenter != 0)
			_yo = (height - element.height) / 2;
		else if (element.layout.alignment & Alignment.Bottom != 0)
			_yo = height - element.height;
		element.setPosition(_x + element.layout.leftMargin, y + _yo);
	}
}
