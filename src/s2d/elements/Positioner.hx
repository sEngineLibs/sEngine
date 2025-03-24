package s2d.elements;

import s2d.Direction;

class Positioner extends Element {
	var slots:Map<Element, {
		widthChanged:Float->Void,
		leftMarginChanged:Float->Void,
		rightMarginChanged:Float->Void,
		heightChanged:Float->Void,
		topMarginChanged:Float->Void,
		bottomMarginChanged:Float->Void
	}> = [];

	@:isVar public var spacing(default, set):Float = 0.0;
	@:inject(rebuild) public var direction:Direction = TopToBottom | LeftToRight;
	@:inject(rebuild) public var axis:Axis = Horizontal;

	public function new(?parent:Element) {
		super(parent);
	}

	@:slot(childAdded)
	function addToPositioning(child:Element) {
		if (axis == Vertical)
			positionV(child, children[child.index - 1]);
		else
			positionH(child, children[child.index - 1]);

		var childSlots = {
			widthChanged: (w:Float) -> adjustElementH(child, RightToLeft, w - child.width),
			leftMarginChanged: (m:Float) -> adjustElementH(child, LeftToRight, child.left.margin - m),
			rightMarginChanged: (m:Float) -> adjustElementH(child, RightToLeft, m - child.right.margin),
			heightChanged: (w:Float) -> adjustElementV(child, BottomToTop, w - child.height),
			topMarginChanged: (m:Float) -> adjustElementV(child, TopToBottom, child.top.margin - m),
			bottomMarginChanged: (m:Float) -> adjustElementV(child, BottomToTop, m - child.bottom.margin)
		};
		slots.set(child, childSlots);

		child.onWidthChanged(childSlots.widthChanged);
		child.left.onMarginChanged(childSlots.leftMarginChanged);
		child.right.onMarginChanged(childSlots.rightMarginChanged);
		child.onHeightChanged(childSlots.heightChanged);
		child.top.onMarginChanged(childSlots.topMarginChanged);
		child.bottom.onMarginChanged(childSlots.bottomMarginChanged);
	}

	@:slot(childRemoved)
	function removeFromPositioning(child:Element) {
		var childSlots = slots.get(child);
		slots.remove(child);

		child.offWidthChanged(childSlots.widthChanged);
		child.left.offMarginChanged(childSlots.leftMarginChanged);
		child.right.offMarginChanged(childSlots.rightMarginChanged);
		child.offHeightChanged(childSlots.heightChanged);
		child.top.offMarginChanged(childSlots.topMarginChanged);
		child.bottom.offMarginChanged(childSlots.bottomMarginChanged);
	}

	@:slot(widthChanged)
	function syncWidth(v:Float) {
		adjustH(RightToLeft, width - v);
	}

	@:slot(left.paddingChanged)
	function syncLeftPadding(v:Float) {
		adjustH(LeftToRight, left.padding - v);
	}

	@:slot(right.paddingChanged)
	function syncRightPadding(v:Float) {
		adjustH(RightToLeft, v - right.padding);
	}

	@:slot(heightChanged)
	function syncHeight(v:Float) {
		adjustV(BottomToTop, height - v);
	}

	@:slot(top.paddingChanged)
	function syncTopPadding(v:Float) {
		adjustV(TopToBottom, top.padding - v);
	}

	@:slot(bottom.paddingChanged)
	function syncBottomPadding(v:Float) {
		if (axis == Vertical)
			adjustV(BottomToTop, v - bottom.padding);
	}

	function positionH(c:Element, prev:Element) {
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

	function positionV(c:Element, prev:Element) {
		if (prev == null) {
			if (direction & BottomToTop != 0)
				c.y = height - (c.height + c.bottom.margin + bottom.padding);
			else
				c.y = top.padding + c.top.margin;
		} else {
			if (direction & BottomToTop != 0)
				c.y = prev.y - (prev.top.margin + spacing + c.bottom.margin + c.height);
			else
				c.y = prev.y + prev.height + prev.bottom.margin + spacing + c.top.margin;
		}
	}

	function adjustH(dir:Direction, d:Float) {
		if (axis == Horizontal)
			if (direction & dir != 0)
				for (c in children)
					c.x += d;
	}

	function adjustV(dir:Direction, d:Float) {
		if (axis == Vertical)
			if (direction & dir != 0)
				for (c in children)
					c.y += d;
	}

	function adjustElementH(e:Element, dir:Alignment, d:Float) {
		if (axis == Horizontal)
			if (direction & dir != 0)
				for (c in children.slice(e.index))
					c.x += d;
			else
				for (c in children.slice(e.index + 1))
					c.x -= d;
	}

	function adjustElementV(e:Element, dir:Alignment, d:Float) {
		if (axis == Vertical)
			if (direction & dir != 0)
				for (c in children.slice(e.index))
					c.y += d;
			else
				for (c in children.slice(e.index + 1))
					c.y -= d;
	}

	function rebuild() {
		if (children.length > 0)
			if (axis == Vertical)
				for (i in 0...visibleChildren.length)
					positionV(visibleChildren[i], visibleChildren[i - 1]);
			else
				for (i in 0...visibleChildren.length)
					positionH(visibleChildren[i], visibleChildren[i - 1]);
	}

	function set_spacing(value:Float):Float {
		var d = value - spacing;
		spacing = value;

		var offset = 0.0;
		if (axis == Vertical) {
			if (direction & RightToLeft != 0)
				d = -d;
			for (c in children) {
				c.x += offset;
				offset += d;
			}
		} else {
			if (direction & BottomToTop != 0)
				d = -d;
			for (c in children) {
				c.y += offset;
				offset += d;
			}
		}
		return spacing;
	}
}

enum Axis {
	Horizontal;
	Vertical;
}
