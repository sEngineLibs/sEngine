package s2d.ui.elements.layouts;

import se.Texture;
import se.math.VectorMath;
import s2d.Alignment;

class ColumnLayout extends UISceneElement {
	public var spacing:Float = 0.0;

	override function addChild(value:UIElement) {
		super.addChild(value);
		build();
	}

	function build() {
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

		var _y = y + top.padding;
		var heightsIndex = 0;
		for (i in 0...elements.length) {
			final e = elements[i];
			var _h;

			if (e.layout.fillHeight) {
				_h = fillCellHeight;
			} else {
				_h = heights[heightsIndex];
				heightsIndex++;
			}

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
			_y += _h + spacing;
		}
	}

	override function renderTree(target:Texture) {
		final ctx = target.context2D;

		syncTransform();
		ctx.transform = _transform;
		ctx.style.opacity = finalOpacity;

		for (child in children)
			if (child.visible)
				child.render(target);
	}
}
