package s2d.elements.layouts;

import s2d.Alignment;

class Layout extends Element {
	var slots:Map<Element, {
		widthChanged:Float->Void,
		heightChanged:Float->Void,
		leftMarginChanged:Float->Void,
		topMarginChanged:Float->Void,
		rightMarginChanged:Float->Void,
		bottomMarginChanged:Float->Void,
		layoutDirty:Void->Void
	}> = [];

	public function new(?parent:Element) {
		super(parent);
	}

	@:slot(childAdded)
	function addToLayout(child:Element):Void {
		var childSlots = {
			widthChanged: (w:Float) -> adjustElementXLayout(child, AlignRight, w - child.width),
			heightChanged: (h:Float) -> adjustElementYLayout(child, AlignBottom, h - child.height),
			leftMarginChanged: (m:Float) -> adjustElementXLayout(child, AlignRight, child.left.margin - m),
			topMarginChanged: (m:Float) -> adjustElementYLayout(child, AlignBottom, child.top.margin - m),
			rightMarginChanged: (m:Float) -> adjustElementXLayout(child, AlignRight, m - child.right.margin),
			bottomMarginChanged: (m:Float) -> adjustElementYLayout(child, AlignBottom, m - child.bottom.margin),
			layoutDirty: () -> {
				if (child.layout.alignment & AlignLeft != 0)
					child.x = left.padding + child.left.margin;
				else if (child.layout.alignment & AlignRight != 0)
					child.x = right - right.padding - child.width;
				else if (child.layout.alignment & AlignHCenter != 0)
					child.x = left.padding + (right - child.width) / 2 - right.padding;
				if (child.layout.alignment & AlignTop != 0)
					child.y = top.padding + child.top.margin;
				else if (child.layout.alignment & AlignBottom != 0)
					child.y = bottom - bottom.padding - child.height;
				else if (child.layout.alignment & AlignVCenter != 0)
					child.y = top.padding + (bottom - child.height) / 2 - bottom.padding;
			}
		};
		slots.set(child, childSlots);

		child.onWidthChanged(childSlots.widthChanged);
		child.onHeightChanged(childSlots.heightChanged);
		child.left.onMarginChanged(childSlots.leftMarginChanged);
		child.top.onMarginChanged(childSlots.topMarginChanged);
		child.right.onMarginChanged(childSlots.rightMarginChanged);
		child.bottom.onMarginChanged(childSlots.bottomMarginChanged);
		child.layout.onDirty(childSlots.layoutDirty);
	}

	@:slot(childRemoved)
	function removeFromLayout(child:Element):Void {
		var childSlots = slots.get(child);
		slots.remove(child);

		child.offWidthChanged(childSlots.widthChanged);
		child.offHeightChanged(childSlots.heightChanged);
		child.left.offMarginChanged(childSlots.leftMarginChanged);
		child.top.offMarginChanged(childSlots.topMarginChanged);
		child.right.offMarginChanged(childSlots.rightMarginChanged);
		child.bottom.offMarginChanged(childSlots.bottomMarginChanged);
		child.layout.offDirty(childSlots.layoutDirty);
	}

	@:slot(widthChanged)
	function _widthChanged(v:Float) {
		adjustXLayout(AlignRight, width - v);
	}

	@:slot(heightChanged)
	function _heightChanged(v:Float) {
		adjustYLayout(AlignBottom, height - v);
	}

	@:slot(left.paddingChanged)
	function _leftPaddingChanged(v:Float) {
		adjustXLayout(AlignLeft, left.padding - v);
	}

	@:slot(top.paddingChanged)
	function _topPaddingChanged(v:Float) {
		adjustYLayout(AlignTop, top.padding - v);
	}

	@:slot(right.paddingChanged)
	function _rightPaddingChanged(v:Float) {
		adjustXLayout(AlignRight, v - right.padding);
	}

	@:slot(bottom.paddingChanged)
	function _bottomPaddingChanged(v:Float) {
		adjustYLayout(AlignBottom, v - bottom.padding);
	}

	function adjustXLayout(a:Alignment, d:Float) {
		final d2 = d / 2;
		for (c in children) {
			if (c.layout.alignment & a != 0)
				c.x += d;
			else if (c.layout.alignment & AlignHCenter != 0)
				c.x += d2;
		}
	}

	function adjustYLayout(a:Alignment, d:Float) {
		final d2 = d / 2;
		for (c in children) {
			if (c.layout.alignment & a != 0)
				c.y += d;
			else if (c.layout.alignment & AlignVCenter != 0)
				c.y += d2;
		}
	}

	function adjustElementXLayout(e:Element, a:Alignment, d:Float) {
		if (e.layout.alignment & a != 0)
			e.x += d;
		else if (e.layout.alignment & AlignHCenter != 0)
			e.x += d / 2;
	}

	function adjustElementYLayout(e:Element, a:Alignment, d:Float) {
		if (e.layout.alignment & a != 0)
			e.y += d;
		else if (e.layout.alignment & AlignVCenter != 0)
			e.y += d / 2;
	}
}
