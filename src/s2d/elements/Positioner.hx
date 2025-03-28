package s2d.elements;

import s2d.Direction;

using se.extensions.ArrayExt;

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
	@:isVar public var direction(default, set):Direction = TopToBottom | LeftToRight;
	@:isVar public var axis(default, set):Axis;

	public function new(axis:Axis = Horizontal) {
		super();
		this.axis = axis;
	}

	override function __childAdded__(child:Element) {
		slots.set(child, {
			widthChanged: (w:Float) -> adjustElementH(child, RightToLeft, w - child.width),
			leftMarginChanged: (m:Float) -> adjustElementH(child, LeftToRight, child.left.margin - m),
			rightMarginChanged: (m:Float) -> adjustElementH(child, RightToLeft, m - child.right.margin),
			heightChanged: (w:Float) -> adjustElementV(child, BottomToTop, w - child.height),
			topMarginChanged: (m:Float) -> adjustElementV(child, TopToBottom, child.top.margin - m),
			bottomMarginChanged: (m:Float) -> adjustElementV(child, BottomToTop, m - child.bottom.margin)
		});
		super.__childAdded__(child);
	}

	override function __childRemoved__(child:Element) {
		super.__childRemoved__(child);
		slots.remove(child);
	}

	@:slot(vChildAdded)
	function trackElement(el:Element) {
		rebuild(vChildren.indexOf(el));
		if (axis == Vertical)
			trackElementV(el);
		else
			trackElementH(el);
	}

	@:slot(vChildRemoved)
	function untrackElement(el:Element) {
		if (axis == Vertical)
			untrackElementV(el);
		else
			untrackElementH(el);
	}

	function trackElementH(el:Element) {
		var childSlots = slots.get(el);
		el.onWidthChanged(childSlots.widthChanged);
		el.left.onMarginChanged(childSlots.leftMarginChanged);
		el.right.onMarginChanged(childSlots.rightMarginChanged);
	}

	function trackElementV(el:Element) {
		var childSlots = slots.get(el);
		el.onHeightChanged(childSlots.heightChanged);
		el.top.onMarginChanged(childSlots.topMarginChanged);
		el.bottom.onMarginChanged(childSlots.bottomMarginChanged);
	}

	function untrackElementH(el:Element) {
		var childSlots = slots.get(el);
		el.offWidthChanged(childSlots.widthChanged);
		el.left.offMarginChanged(childSlots.leftMarginChanged);
		el.right.offMarginChanged(childSlots.rightMarginChanged);
	}

	function untrackElementV(el:Element) {
		var childSlots = slots.get(el);
		el.offWidthChanged(childSlots.widthChanged);
		el.left.offMarginChanged(childSlots.leftMarginChanged);
		el.right.offMarginChanged(childSlots.rightMarginChanged);
	}

	function syncWidth(v:Float) {
		adjustH(RightToLeft, width - v);
	}

	function syncLeftPadding(v:Float) {
		adjustH(LeftToRight, left.padding - v);
	}

	function syncRightPadding(v:Float) {
		adjustH(RightToLeft, v - right.padding);
	}

	function syncHeight(v:Float) {
		adjustV(BottomToTop, height - v);
	}

	function syncTopPadding(v:Float) {
		adjustV(TopToBottom, top.padding - v);
	}

	function syncBottomPadding(v:Float) {
		adjustV(BottomToTop, v - bottom.padding);
	}

	function positionH(el:Element, prev:Element) {
		if (prev == null) {
			if (direction & RightToLeft != 0)
				el.x = width - (el.width + el.right.margin + right.padding);
			else
				el.x = el.left.margin;
		} else {
			if (direction & RightToLeft != 0)
				el.x = prev.x - (prev.left.margin + spacing + el.right.margin + el.width);
			else
				el.x = prev.x + prev.width + prev.right.margin + spacing + el.left.margin;
		}
	}

	function positionV(el:Element, prev:Element) {
		if (prev == null) {
			if (direction & BottomToTop != 0)
				el.y = height - (el.height + el.bottom.margin + bottom.padding);
			else
				el.y = el.top.margin;
		} else {
			if (direction & BottomToTop != 0)
				el.y = prev.y - (prev.top.margin + spacing + el.bottom.margin + el.height);
			else
				el.y = prev.y + prev.height + prev.bottom.margin + spacing + el.top.margin;
		}
	}

	function adjustH(dir:Direction, d:Float) {
		if (direction & dir != 0)
			for (c in vChildren)
				c.x += d;
	}

	function adjustV(dir:Direction, d:Float) {
		if (direction & dir != 0)
			for (c in vChildren)
				c.y += d;
	}

	function adjustElementH(el:Element, dir:Alignment, d:Float) {
		if (direction & dir != 0)
			for (i in el.index...vChildren.length)
				vChildren[i].x += d;
		else
			for (i in (el.index + 1)...vChildren.length)
				vChildren[i].x -= d;
	}

	function adjustElementV(el:Element, dir:Alignment, d:Float) {
		if (direction & dir != 0)
			for (i in el.index...vChildren.length)
				vChildren[i].y += d;
		else
			for (i in (el.index + 1)...vChildren.length)
				vChildren[i].y -= d;
	}

	function rebuild(offset:Int = 0) {
		if (axis == Vertical)
			rebuildV(offset);
		else
			rebuildH(offset);
	}

	function rebuildH(offset:Int = 0) {
		if (vChildren.length > 0)
			for (i in offset...vChildren.length)
				positionH(vChildren[i], vChildren[i - 1]);
	}

	function rebuildV(offset:Int = 0) {
		if (vChildren.length > 0)
			for (i in offset...vChildren.length)
				positionV(vChildren[i], vChildren[i - 1]);
	}

	function set_spacing(value:Float):Float {
		var d = value - spacing;
		spacing = value;

		var offset = 0.0;
		if (axis == Vertical) {
			if (direction & BottomToTop != 0)
				d = -d;
			for (c in vChildren) {
				c.y += offset;
				offset += d;
			}
		} else {
			if (direction & RightToLeft != 0)
				d = -d;
			for (c in vChildren) {
				c.x += offset;
				offset += d;
			}
		}
		return spacing;
	}

	function set_direction(value:Direction):Direction {
		direction = value;
		rebuild();
		return direction;
	}

	function set_axis(value:Axis) {
		axis = value;
		if (axis == Vertical) {
			for (c in vChildren) {
				untrackElementH(c);
				trackElementV(c);
			}
			offWidthChanged(syncWidth);
			left.offPaddingChanged(syncLeftPadding);
			right.offPaddingChanged(syncRightPadding);
			onHeightChanged(syncHeight);
			top.onPaddingChanged(syncTopPadding);
			bottom.onPaddingChanged(syncBottomPadding);
		} else {
			for (c in vChildren) {
				untrackElementV(c);
				trackElementH(c);
			}
			offHeightChanged(syncHeight);
			top.offPaddingChanged(syncTopPadding);
			bottom.offPaddingChanged(syncBottomPadding);
			onWidthChanged(syncWidth);
			left.onPaddingChanged(syncLeftPadding);
			right.onPaddingChanged(syncRightPadding);
		}
		rebuild();
		return axis;
	}
}

enum Axis {
	Horizontal;
	Vertical;
}
