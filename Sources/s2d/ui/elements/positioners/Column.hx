package s2d.ui.elements.positioners;

import s2d.Alignment;

class Column extends Positioner {
	function position(element:UIElement) {
		var _y = prevBounds.bottom + spacing;

		var _xo = element.layout.leftMargin;
		if (element.layout.alignment & Alignment.HCenter != 0)
			_xo = (width - element.width) / 2;
		else if (element.layout.alignment & Alignment.Right != 0)
			_xo = width - element.width;
		element.setPosition(x + _xo, _y + element.layout.topMargin);
	}
}
