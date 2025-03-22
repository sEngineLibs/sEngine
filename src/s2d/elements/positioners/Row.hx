package s2d.elements.positioners;

import s2d.Direction;

class Row extends DirectionalPositioner<RowSlots> {
	public function new(?parent:Element) {
		super(parent);
	}

	function position(c:Element, prev:Element) {
		if (prev == null) {
			if (direction & RightToLeft != 0)
				c.x = width - (c.width + c.right.margin + right.padding);
			else
				c.x = left.padding + c.left.margin;
		} else {
			if (direction & RightToLeft != 0)
				c.x = prev.x - (prev.left.margin + spacing + c.right.margin + c.width);
			else
				c.x = prev.x + prev.width + prev.right.margin + spacing + c.left.margin;
		}
	}

	function addToPositioning(child:Element):RowSlots {
		var childSlots = {
			widthChanged: (w:Float) -> adjustElement(child, RightToLeft, w - child.width),
			leftMarginChanged: (m:Float) -> adjustElement(child, LeftToRight, child.left.margin - m),
			rightMarginChanged: (m:Float) -> adjustElement(child, RightToLeft, m - child.right.margin)
		};
		child.onWidthChanged(childSlots.widthChanged);
		child.left.onMarginChanged(childSlots.leftMarginChanged);
		child.right.onMarginChanged(childSlots.rightMarginChanged);
		return childSlots;
	}

	function removeFromPositioning(child:Element):Void {
		var childSlots = slots.get(child);
		child.offWidthChanged(childSlots.widthChanged);
		child.left.offMarginChanged(childSlots.leftMarginChanged);
		child.right.offMarginChanged(childSlots.rightMarginChanged);
	}

	@:slot(widthChanged)
	function syncWidth(v:Float) {
		adjust(RightToLeft, width - v);
	}

	@:slot(left.paddingChanged)
	function syncLeftPadding(v:Float) {
		adjust(LeftToRight, left.padding - v);
	}

	@:slot(right.paddingChanged)
	function syncRightPadding(v:Float) {
		adjust(RightToLeft, v - right.padding);
	}

	function adjustSpacing(d:Float) {
		if (direction & RightToLeft != 0)
			d = -d;

		var offset = 0.0;
		for (c in children) {
			c.x += offset;
			offset += d;
		}
	}

	function adjust(dir:Direction, d:Float) {
		if (direction & dir != 0)
			for (c in children)
				c.x += d;
	}

	function adjustElement(e:Element, dir:Alignment, d:Float) {
		if (direction & dir != 0)
			for (c in children.slice(e.index))
				c.x += d;
		else
			for (c in children.slice(e.index + 1))
				c.x -= d;
	}
}

private typedef RowSlots = {
	widthChanged:Float->Void,
	leftMarginChanged:Float->Void,
	rightMarginChanged:Float->Void
}
