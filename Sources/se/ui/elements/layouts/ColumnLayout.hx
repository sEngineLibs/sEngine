package se.ui.elements.layouts;

import kha.Canvas;
import se.math.VectorMath;
import se.ui.positioning.Alignment;

class ColumnLayout extends UIElement {
	public var spacing:Float = 0.0;

	override function renderTree(target:Canvas) {
		var elements = [];
		var heights = [];
		var cellsHeight = 0.0;
		var fillCellCount = 0;

		final crect = contentRect;

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

		final fillCellHeight = fillCellCount > 0 ? (crect.height - (elements.length - 1) * spacing - cellsHeight) / fillCellCount : 0;

		target.g2.color = color;
		target.g2.opacity = finalOpacity;
		target.g2.transformation = finalModel;

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
				_w = clamp(e.width, 0.0, crect.width);
				if (e.layout.alignment & Alignment.HCenter != 0)
					xo += (crect.width - _w) / 2;
				else if (e.layout.alignment & Alignment.Right != 0)
					xo += crect.width - _w;
			} else {
				_w = crect.width - e.layout.leftMargin - e.layout.rightMargin;
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
