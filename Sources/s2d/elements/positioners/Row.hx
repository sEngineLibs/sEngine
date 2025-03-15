package s2d.elements.positioners;

import s2d.Alignment;

class Row extends Positioner {
	function position(element:Element) {
		var _x = prevBounds.right + spacing;

		var _yo = element.top.margin;
		if (element.layout.alignment & AlignVCenter != 0)
			_yo = (height - element.height) / 2;
		else if (element.layout.alignment & AlignBottom != 0)
			_yo = height - element.height;
		element.setPosition(_x + element.left.margin, y + _yo);
	}
}
