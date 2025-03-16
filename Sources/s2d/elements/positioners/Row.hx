package s2d.elements.positioners;

import s2d.Direction;

class Row extends Positioner<RowSlots> {
	public function new(?parent:Element) {
		super(parent);
	}

	function addToPositioning(child:Element):RowSlots {
		var childSlots = {
			widthChanged: (w:Float) -> adjustElementXPositioning(child, LeftToRight, w - child.width),
			leftMarginChanged: (m:Float) -> adjustElementXPositioning(child, RightToLeft, m - child.left.margin),
			rightMarginChanged: (m:Float) -> adjustElementXPositioning(child, LeftToRight, child.left.margin - m)
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

	function position(el:Element, prev:Element) {
		if (prev != null) {
			if (direction & LeftToRight != 0)
				el.x = prev.right.position + prev.right.margin + spacing + el.left.margin;
			else
				el.x = prev.left.position - prev.left.margin - spacing - el.right.margin - el.width;
		} else {
			if (direction & LeftToRight != 0)
				el.x = spacing + el.left.margin;
			else
				el.x = right.position - spacing - el.right.margin - el.width;
		}
	}

	@:slot(widthChanged)
	function __widthChanged(v:Float) {
		adjustXPositioning(RightToLeft, width - v);
	}

	@:slot(left.paddingChanged)
	function __leftPaddingChanged(v:Float) {
		adjustXPositioning(LeftToRight, left.padding - v);
	}

	@:slot(right.paddingChanged)
	function __rightPaddingChanged(v:Float) {
		adjustXPositioning(RightToLeft, right.padding - v);
	}
}

private typedef RowSlots = {
	widthChanged:Float->Void,
	leftMarginChanged:Float->Void,
	rightMarginChanged:Float->Void
}
