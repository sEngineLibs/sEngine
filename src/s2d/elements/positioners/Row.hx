package s2d.elements.positioners;

import s2d.Direction;

class Row extends Positioner<RowSlots> {
	public function new(?parent:Element) {
		super(parent);
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

	function position(c:Element, prev:Element) {
		if (prev == null) {
			if (direction & RightToLeft != 0)
				c.x = right.position - c.right.margin - c.width;
			else
				c.x = c.left.margin;
		} else {
			if (direction & RightToLeft != 0)
				c.x = prev.left.position - (prev.left.margin + spacing + c.right.margin + c.width);
			else
				c.x = prev.right.position + prev.right.margin + spacing + c.left.margin;
		}
	}

	@:slot(widthChanged)
	function __widthChanged(v:Float) {
		adjust(RightToLeft, width - v);
	}

	@:slot(left.paddingChanged)
	function __leftPaddingChanged(v:Float) {
		adjust(LeftToRight, left.padding - v);
	}

	@:slot(right.paddingChanged)
	function __rightPaddingChanged(v:Float) {
		adjust(RightToLeft, right.padding - v);
	}

	function rebuild() {
		var prev = children[0];
		if (direction & RightToLeft != 0) {
			prev.x = right.position - prev.right.margin - prev.width;
			for (c in children.slice(1)) {
				c.x = prev.left.position - (prev.left.margin + spacing + c.right.margin + c.width);
				prev = c;
			}
		} else {
			prev.x = prev.left.margin;
			for (c in children.slice(1)) {
				c.x = right.position - c.right.margin - c.width;
				prev = c;
			}
		}
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
