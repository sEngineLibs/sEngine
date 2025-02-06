package s2d.ui.elements.layouts;

import kha.Canvas;
// s2d
import s2d.math.VectorMath;
import s2d.ui.positioning.Alignment;

class RowLayout extends UIElement {
	public var spacing:Float = 0.0;

	override function renderTree(target:Canvas) {
		var elements = [];
		var widths = [];
		var cellsWidth = 0.0;
		var fillCellCount = 0;

		final avwidth = availableWidth;
		final avheight = availableHeight;

		for (child in children) {
			if (child.visible) {
				if (child.layout.fillWidth) {
					++fillCellCount;
				} else {
					var w = child.width - child.layout.leftMargin - child.layout.rightMargin;
					widths.push(w);
					cellsWidth += w;
				}
				elements.push(child);
			}
		}

		final fillCellWidth = fillCellCount > 0 ? (avwidth - (elements.length - 1) * spacing - cellsWidth) / fillCellCount : 0;

		var _x = x + left.padding;
		for (i in 0...elements.length) {
			final e = elements[i];
			final _w = e.layout.fillWidth ? fillCellWidth : widths[i];

			var _y = y + top.padding;
			var _h;

			// x offset
			final xo = e.layout.leftMargin;
			// y offset
			var yo = e.layout.topMargin;
			// cell height
			if (!e.layout.fillHeight) {
				_h = clamp(e.height, 0.0, avheight);
				if (e.layout.alignment & Alignment.VCenter != 0)
					yo += (avheight - _h) / 2;
				else if (e.layout.alignment & Alignment.Bottom != 0)
					yo += avheight - _h;
			} else {
				_h = avheight - e.layout.topMargin - e.layout.bottomMargin;
			}

			e.x = _x + xo;
			e.y = _y + yo;
			e.width = _w;
			e.height = _h;
			e.render(target);

			_x += _w + spacing;
		}
	}
}
