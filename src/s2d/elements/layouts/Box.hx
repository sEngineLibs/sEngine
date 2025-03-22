package s2d.elements.layouts;

import s2d.Alignment;

class Box extends Element {
	var cell:MultiElementBoxCell = new MultiElementBoxCell();

	public function new(?parent:Element) {
		super(parent);
	}

	override function __childAdded__(child:Element) {
		super.__childAdded__(child);
		if (child.visible)
			cell.add(child);
		var slot = v -> {
			if (!v && child.visible)
				cell.add(child);
			else if (v && !child.visible)
				cell.remove(child);
		};
		child.onVisibleChanged(slot);
		child.onParentChanged(_ -> child.offVisibleChanged(slot));
	}

	override function __childRemoved__(child:Element) {
		super.__childRemoved__(child);
		if (child.visible)
			cell.remove(child);
	}

	@:slot(widthChanged)
	function syncWidth(previous:Float) {
		cell.right += width - previous;
	}

	@:slot(heightChanged)
	function syncHeight(previous:Float) {
		cell.bottom += height - previous;
	}

	@:slot(left.paddingChanged)
	function syncLeftPadding(previous:Float) {
		cell.left += left.padding - previous;
	}

	@:slot(top.paddingChanged)
	function syncTopPadding(previous:Float) {
		cell.top += top.padding - previous;
	}

	@:slot(right.paddingChanged)
	function syncRightPadding(previous:Float) {
		cell.right += previous - right.padding;
	}

	@:slot(bottom.paddingChanged)
	function syncBottomPadding(previous:Float) {
		cell.bottom += previous - bottom.padding;
	}
}

abstract class BoxCell {
	static function adjustElementH(el:Element, alignment:Alignment, d:Float) {
		if (el.layout.alignment & alignment != 0)
			el.x += d;
		else if (el.layout.alignment & AlignHCenter != 0)
			el.x += d * 0.5;
	}

	static function adjustElementV(el:Element, alignment:Alignment, d:Float) {
		if (el.layout.alignment & alignment != 0)
			el.y += d;
		else if (el.layout.alignment & AlignVCenter != 0)
			el.y += d * 0.5;
	}

	@:isVar public var left(default, set):Float = 0.0;
	@:isVar public var top(default, set):Float = 0.0;
	@:isVar public var right(default, set):Float = 0.0;
	@:isVar public var bottom(default, set):Float = 0.0;

	public function add(el:Element) {
		fit(el);

		var slots = {
			widthChanged: (w:Float) -> {
				if (!el.layout.fillWidth)
					BoxCell.adjustElementH(el, AlignRight, w - el.width);
			},
			heightChanged: (h:Float) -> {
				if (!el.layout.fillHeight)
					BoxCell.adjustElementV(el, AlignBottom, h - el.height);
			},
			leftMarginChanged: (m:Float) -> BoxCell.adjustElementH(el, AlignLeft, el.left.margin - m),
			topMarginChanged: (m:Float) -> BoxCell.adjustElementV(el, AlignTop, el.top.margin - m),
			rightMarginChanged: (m:Float) -> BoxCell.adjustElementH(el, AlignRight, m - el.right.margin),
			bottomMarginChanged: (m:Float) -> BoxCell.adjustElementV(el, AlignBottom, m - el.bottom.margin),
			layout: {
				alignmentChanged: a -> fit(el),
				fillWidthChanged: fw -> {
					if (!fw && el.layout.fillWidth)
						fillH(el);
					else if (fw && !el.layout.fillWidth)
						fitH(el);
				},
				fillHeightChanged: fh -> {
					if (!fh && el.layout.fillHeight)
						fillV(el);
					else if (fh && !el.layout.fillHeight)
						fitV(el);
				}
			}
		};

		el.onWidthChanged(slots.widthChanged);
		el.onHeightChanged(slots.heightChanged);
		el.left.onMarginChanged(slots.leftMarginChanged);
		el.top.onMarginChanged(slots.topMarginChanged);
		el.right.onMarginChanged(slots.rightMarginChanged);
		el.bottom.onMarginChanged(slots.bottomMarginChanged);
		el.layout.onAlignmentChanged(slots.layout.alignmentChanged);
		el.layout.onFillWidthChanged(slots.layout.fillWidthChanged);
		el.layout.onFillHeightChanged(slots.layout.fillHeightChanged);
		addElementSlots(el, slots);
	}

	public function remove(el:Element) {
		var slots = removeElementSlots(el);

		el.offWidthChanged(slots.widthChanged);
		el.offHeightChanged(slots.heightChanged);
		el.left.offMarginChanged(slots.leftMarginChanged);
		el.top.offMarginChanged(slots.topMarginChanged);
		el.right.offMarginChanged(slots.rightMarginChanged);
		el.bottom.offMarginChanged(slots.bottomMarginChanged);
		el.layout.offAlignmentChanged(slots.layout.alignmentChanged);
		el.layout.offFillWidthChanged(slots.layout.fillWidthChanged);
		el.layout.offFillHeightChanged(slots.layout.fillHeightChanged);
	}

	abstract function addElementSlots(el:Element, slots:ElementSlots):Void;

	abstract function removeElementSlots(el:Element):ElementSlots;

	abstract function adjustH(alignment:Alignment, d:Float):Void;

	abstract function adjustV(alignment:Alignment, d:Float):Void;

	function fit(el:Element) {
		if (el.layout.fillWidth)
			fillH(el);
		else
			fitH(el);
		if (el.layout.fillHeight)
			fillV(el);
		else
			fitV(el);
	}

	function fitH(el:Element) {
		if (el.layout.alignment & AlignRight != 0)
			el.x = right - (el.width + el.right.margin);
		else if (el.layout.alignment & AlignHCenter != 0) {
			el.x = left + (right - left - (el.width + el.left.margin + el.right.margin)) / 2;
		} else
			el.x = left + el.left.margin;
	}

	function fitV(el:Element) {
		if (el.layout.alignment & AlignBottom != 0)
			el.y = bottom - (el.height + el.bottom.margin);
		else if (el.layout.alignment & AlignVCenter != 0)
			el.y = top + (bottom - top - (el.height + el.top.margin + el.bottom.margin)) / 2;
		else
			el.y = top + el.top.margin;
	}

	function fillH(el:Element) {
		el.x = left + el.left.margin;
		el.width = right - left;
	}

	function fillV(el:Element) {
		el.y = top + el.top.margin;
		el.height = bottom - top;
	}

	function set_left(value:Float):Float {
		final d = left - value;
		left = value;
		adjustH(AlignLeft, d);
		return left;
	}

	function set_top(value:Float):Float {
		final d = top - value;
		top = value;
		adjustV(AlignTop, d);
		return top;
	}

	function set_right(value:Float):Float {
		final d = value - right;
		right = value;
		adjustH(AlignRight, d);
		return right;
	}

	function set_bottom(value:Float):Float {
		final d = value - bottom;
		bottom = value;
		adjustV(AlignBottom, d);
		return bottom;
	}
}

class SingleElementBoxCell extends BoxCell {
	var element:Element;
	var slots:ElementSlots;

	public function new(el:Element) {
		element = el;
		add(element);
	}

	function addElementSlots(_, slots:ElementSlots) {
		this.slots = slots;
	}

	function removeElementSlots(_):ElementSlots {
		return slots;
	}

	function adjustH(alignment:Alignment, d:Float) {
		if (element.layout.fillWidth)
			fillH(element);
		else
			BoxCell.adjustElementH(element, alignment, d);
	}

	function adjustV(alignment:Alignment, d:Float) {
		if (element.layout.fillHeight)
			fillV(element);
		else
			BoxCell.adjustElementV(element, alignment, d);
	}
}

class MultiElementBoxCell extends BoxCell {
	var elements:Map<Element, ElementSlots> = [];

	public function new() {}

	function addElementSlots(el:Element, slots:ElementSlots) {
		elements.set(el, slots);
	}

	function removeElementSlots(el:Element):ElementSlots {
		var slots = elements.get(el);
		elements.remove(el);
		return slots;
	}

	function adjustH(alignment:Alignment, d:Float) {
		for (c in elements.keys())
			if (c.layout.fillWidth)
				fillH(c);
			else
				BoxCell.adjustElementH(c, alignment, d);
	}

	function adjustV(alignment:Alignment, d:Float) {
		for (c in elements.keys())
			if (c.layout.fillHeight)
				fillV(c);
			else
				BoxCell.adjustElementV(c, alignment, d);
	}
}

private typedef ElementSlots = {
	widthChanged:Float->Void,
	heightChanged:Float->Void,
	leftMarginChanged:Float->Void,
	topMarginChanged:Float->Void,
	rightMarginChanged:Float->Void,
	bottomMarginChanged:Float->Void,
	layout:{
		alignmentChanged:Alignment->Void, fillWidthChanged:Bool->Void, fillHeightChanged:Bool->Void
	}
}
