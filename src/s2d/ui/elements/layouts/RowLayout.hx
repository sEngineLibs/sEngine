package s2d.ui.elements.layouts;

import kha.Canvas;
// s2d
import s2d.math.VectorMath;
import s2d.ui.positioning.Alignment;

class RowLayout extends UIElement {
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

		var cells = [];
		var cellsWidth = 0.0;
		var fillCellCount = 0;
		for (child in children) {
			if (child.visible) {
				var cell = {
					element: child,
					width: null
				}
				if (child.layout.fillWidth)
					++fillCellCount;
				else {
					var w = child.width - child.layout.leftMargin - child.layout.rightMargin;
					cell.width = w;
					cellsWidth += w;
				}
				cells.push(cell);
			}
		}

		var fillCellWidth = 1 / fillCellCount * (availableWidth - (cells.length - 1) * spacing - cellsWidth);

		var _x = x + left.padding;
		for (c in cells) {
			final e = c.element;

			var _y = y + top.padding;
			var _w, _h;

			// x offset
			var xo = e.layout.leftMargin;
			// y offset
			var yo = e.layout.topMargin;
			// cell height
			if (!e.layout.fillHeight) {
				_h = clamp(e.height, 0.0, availableHeight);
				if (e.layout.alignment & Alignment.VCenter != 0)
					yo += (availableHeight - _h) / 2;
				else if (e.layout.alignment & Alignment.Bottom != 0)
					yo += availableHeight - _h;
			} else
				_h = availableHeight - e.layout.topMargin - e.layout.bottomMargin;
			// cell width
			if (e.layout.fillWidth)
				_w = fillCellWidth;
			else
				_w = c.width;

			e.setPosition(_x + xo, _y + yo);
			e.setSize(_w, _h);
			e.render(target);

			_x += _w + spacing;
		}
	}
}
