package s2d.elements.positioners;

import s2d.Direction;

class Column extends Positioner<ColumnSlots> {
	public function new(?parent:Element) {
		super(parent);
	}

	function addToPositioning(child:Element):ColumnSlots {
		var childSlots = {
			heightChanged: (h:Float) -> adjustElement(child, BottomToTop, h - child.height),
			topMarginChanged: (m:Float) -> adjustElement(child, TopToBottom, child.top.margin - m),
			bottomMarginChanged: (m:Float) -> adjustElement(child, BottomToTop, m - child.bottom.margin)
		};
		child.onHeightChanged(childSlots.heightChanged);
		child.top.onMarginChanged(childSlots.topMarginChanged);
		child.bottom.onMarginChanged(childSlots.bottomMarginChanged);
		return childSlots;
	}

	function removeFromPositioning(child:Element):Void {
		var childSlots = slots.get(child);
		child.offHeightChanged(childSlots.heightChanged);
		child.top.offMarginChanged(childSlots.topMarginChanged);
		child.bottom.offMarginChanged(childSlots.bottomMarginChanged);
	}

	function position(c:Element, prev:Element) {
		if (prev == null) {
			if (direction & BottomToTop != 0)
				c.y = bottom.position - c.bottom.margin - c.height;
			else
				c.y = c.top.margin;
		} else {
			if (direction & BottomToTop != 0)
				c.y = prev.top.position - (prev.top.margin + spacing + c.bottom.margin + c.height);
			else
				c.y = prev.bottom.position + prev.bottom.margin + spacing + c.top.margin;
		}
	}

	@:slot(heightChanged)
	function __heightChanged(v:Float) {
		adjust(BottomToTop, height - v);
	}

	@:slot(top.paddingChanged)
	function __topPaddingChanged(v:Float) {
		adjust(TopToBottom, top.padding - v);
	}

	@:slot(bottom.paddingChanged)
	function __bottomPaddingChanged(v:Float) {
		adjust(BottomToTop, bottom.padding - v);
	}

	function rebuild() {
		var prev = children[0];
		if (direction & BottomToTop != 0) {
			prev.y = bottom.position - prev.bottom.margin - prev.height;
			for (c in children.slice(1)) {
				c.y = prev.top.position - (prev.top.margin + spacing + c.bottom.margin + c.height);
				prev = c;
			}
		} else {
			prev.y = prev.top.margin;
			for (c in children.slice(1)) {
				c.y = bottom.position - c.bottom.margin - c.height;
				prev = c;
			}
		}
	}

	function adjustSpacing(d:Float) {
		if (direction & BottomToTop != 0)
			d = -d;

		var offset = 0.0;
		for (c in children) {
			c.y += offset;
			offset += d;
		}
	}

	function adjust(dir:Direction, d:Float) {
		if (direction & dir != 0)
			for (c in children)
				c.y += d;
	}

	function adjustElement(e:Element, dir:Alignment, d:Float) {
		if (direction & dir != 0)
			for (c in children.slice(e.index))
				c.y += d;
		else
			for (c in children.slice(e.index + 1))
				c.y -= d;
	}
}

private typedef ColumnSlots = {
	heightChanged:Float->Void,
	topMarginChanged:Float->Void,
	bottomMarginChanged:Float->Void
}
