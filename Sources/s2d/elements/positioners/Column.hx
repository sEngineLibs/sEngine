package s2d.elements.positioners;

import s2d.Alignment;

class Column extends Positioner {
	function position(element:Element) {
		var _y = prevBounds.bottom + spacing;

		var _xo = element.left.margin;
		if (element.layout.alignment & AlignHCenter != 0)
			_xo = (width - element.width) / 2;
		else if (element.layout.alignment & AlignRight != 0)
			_xo = width - element.width;
		element.setPosition(x + _xo, _y + element.top.margin);
	}
}
