package s2d.elements.positioners;

import s2d.Direction;

class Column extends Positioner<ColumnSlots> {
	public function new(?parent:Element) {
		super(parent);
	}

	function addToPositioning(child:Element):ColumnSlots {
		var childSlots = {
			heightChanged: (h:Float) -> adjustElementYPositioning(child, BottomToTop, h - child.height),
			topMarginChanged: (m:Float) -> adjustElementYPositioning(child, BottomToTop, m - child.top.margin),
			bottomMarginChanged: (m:Float) -> adjustElementYPositioning(child, TopToBottom, child.top.margin - m)
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

	function position(el:Element, prev:Element) {
		if (prev != null) {
			if (direction & TopToBottom != 0)
				el.y = prev.bottom.position + prev.bottom.margin + spacing + el.top.margin;
			else
				el.y = prev.top.position - prev.top.margin - spacing - el.bottom.margin - el.width;
		} else {
			if (direction & TopToBottom != 0)
				el.y = spacing + el.top.margin;
			else
				el.y = bottom.position - spacing - el.bottom.margin - el.width;
		}
	}

	@:slot(heightChanged)
	function __heightChanged(v:Float) {
		adjustYPositioning(BottomToTop, height - v);
	}

	@:slot(top.paddingChanged)
	function __topPaddingChanged(v:Float) {
		adjustYPositioning(TopToBottom, top.padding - v);
	}

	@:slot(bottom.paddingChanged)
	function __bottomPaddingChanged(v:Float) {
		adjustYPositioning(BottomToTop, bottom.padding - v);
	}
}

private typedef ColumnSlots = {
	heightChanged:Float->Void,
	topMarginChanged:Float->Void,
	bottomMarginChanged:Float->Void
}
