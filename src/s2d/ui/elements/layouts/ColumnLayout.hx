package s2d.ui.elements.layouts;

import kha.Canvas;
// s2d
import s2d.math.VectorMath;
import s2d.ui.positioning.Alignment;

class ColumnLayout extends UIElement {
	public var spacing:Float = 0.0;

	override function renderTree(target:Canvas) {
		var elements = [];
		var heights = [];
		var cellsHeight = 0.0;
		var fillCellCount = 0;

		final avwidth = availableWidth;
		final avheight = availableHeight;

		for (child in children) {
			if (child.visible) {
				if (child.layout.fillHeight) {
					++fillCellCount;
				} else {
					var h = child.height - child.layout.topMargin - child.layout.bottomMargin;
					heights.push(h);
					cellsHeight += h;
				}
				elements.push(child);
			}
		}

		final fillCellHeight = fillCellCount > 0 ? (avheight - (elements.length - 1) * spacing - cellsHeight) / fillCellCount : 0;

		var _y = y + top.padding;
		for (i in 0...elements.length) {
			final e = elements[i];
			final _h = e.layout.fillHeight ? fillCellHeight : heights[i];

			var _x = x + left.padding;
			var _w;

			// x offset
			var xo = e.layout.leftMargin;
			// y offset
			final yo = e.layout.topMargin;
			// cell width
			if (!e.layout.fillWidth) {
				_w = clamp(e.width, 0.0, avwidth);
				if (e.layout.alignment & Alignment.HCenter != 0)
					xo += (avwidth - _w) / 2;
				else if (e.layout.alignment & Alignment.Right != 0)
					xo += avwidth - _w;
			} else {
				_w = avwidth - e.layout.leftMargin - e.layout.rightMargin;
			}

			e.x = _x + xo;
			e.y = _y + yo;
			e.width = _w;
			e.height = _h;
			e.render(target);

			_y += _h + spacing;
		}
	}
}
