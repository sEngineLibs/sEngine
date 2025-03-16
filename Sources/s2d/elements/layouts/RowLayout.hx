package s2d.elements.layouts;

import se.Texture;
import se.math.VectorMath;
import s2d.Alignment;

class RowLayout extends Element {
	var effective:Array<Element> = [];

	public var spacing:Float = 0.0;
	public var direction:Direction = RightToLeft;

	public function new(?parent:Element) {
		super(parent);
	}

	@:slot(childAdded)
	function addToLayout(child:Element):Void {
		child.layout.onDirty(update);
		update();
	}

	@:slot(childRemoved)
	function removeFromLayout(child:Element):Void {
		child.layout.offDirty(update);
		update();
	}

	function update() {
		var elements = [];
		var widths = [];
		var cellsWidth = 0.0;
		var fillCellCount = 0;

		final crect = contentRect;

		for (child in children) {
			if (child.visible) {
				if (child.layout.fillWidth)
					++fillCellCount;
				else {
					var w = child.width - child.left.margin - child.right.margin;
					widths.push(w);
					cellsWidth += w;
				}
				elements.push(child);
			}
		}

		final fillCellWidth = fillCellCount > 0 ? (crect.width - (elements.length - 1) * spacing - cellsWidth) / fillCellCount : 0;

		var _x = x + left.padding;
		var widthsIndex = 0;
		for (i in 0...elements.length) {
			final e = elements[i];
			var _w;

			if (e.layout.fillWidth)
				_w = fillCellWidth;
			else
				_w = widths[widthsIndex++];

			var _y = y + top.padding;
			var _h;

			// x offset
			final xo = e.left.margin;
			// y offset
			var yo = e.top.margin;
			// cell height
			if (!e.layout.fillHeight) {
				_h = clamp(e.height, 0.0, crect.height);
				if (e.layout.alignment & AlignVCenter != 0)
					yo += (crect.height - _h) / 2;
				else if (e.layout.alignment & AlignBottom != 0)
					yo += crect.height - _h;
			} else {
				_h = crect.height - e.top.margin - e.bottom.margin;
			}

			e.x = _x + xo;
			e.y = _y + yo;
			e.width = _w;
			e.height = _h;

			_x += _w + spacing;
		}
	}

	override function render(target:Texture) {
		final ctx = target.ctx2D;
		ctx.style.pushOpacity(opacity);
		ctx.transform = globalTransform;
		for (c in children)
			c.render(target);
		ctx.style.popOpacity();
	}
}
