package s2d;

import se.math.VectorMath;
import s2d.Anchors;
import s2d.Alignment;

abstract class Box {
	static function adjustElementWidth(el:Element, alignment:Alignment, d:Float) {
		if (!el.layout.fillWidth)
			if (el.layout.alignment & alignment != 0)
				el.x += d;
			else if (el.layout.alignment & AlignHCenter != 0)
				el.x += d * 0.5;
	}

	static function adjustElementHeight(el:Element, alignment:Alignment, d:Float) {
		if (!el.layout.fillHeight)
			if (el.layout.alignment & alignment != 0)
				el.y += d;
			else if (el.layout.alignment & AlignVCenter != 0)
				el.y += d * 0.5;
	}

	public var left:AnchorLine;
	public var top:AnchorLine;
	public var right:AnchorLine;
	public var bottom:AnchorLine;

	public function new(left:AnchorLine, top:AnchorLine, right:AnchorLine, bottom:AnchorLine) {
		this.left = left;
		this.top = top;
		this.right = right;
		this.bottom = bottom;

		left.onPositionChanged((previous:Float) -> adjustWidth(AlignLeft, left.position - previous));
		top.onPositionChanged((previous:Float) -> adjustHeight(AlignTop, top.position - previous));
		right.onPositionChanged((previous:Float) -> adjustWidth(AlignRight, right.position - previous));
		bottom.onPositionChanged((previous:Float) -> adjustHeight(AlignBottom, bottom.position - previous));
	}

	public function add(el:Element) {
		fit(el);
		fill(el);
		var slots = {
			widthChanged: (w:Float) -> {
				Box.adjustElementWidth(el, AlignRight, w - el.width);
			},
			heightChanged: (h:Float) -> Box.adjustElementHeight(el, AlignBottom, h - el.height),
			leftMarginChanged: (m:Float) -> Box.adjustElementWidth(el, AlignLeft, el.left.margin - m),
			topMarginChanged: (m:Float) -> Box.adjustElementHeight(el, AlignTop, el.top.margin - m),
			rightMarginChanged: (m:Float) -> Box.adjustElementWidth(el, AlignRight, m - el.right.margin),
			bottomMarginChanged: (m:Float) -> Box.adjustElementHeight(el, AlignBottom, m - el.bottom.margin),
			layout: {
				alignmentChanged: a -> fit(el),
				fillWidthChanged: fw -> {
					if (!fw && el.layout.fillWidth)
						fillWidth(el);
					else if (fw && !el.layout.fillWidth) {
						unfillWidth(el);
						fitWidth(el);
					}
				},
				fillHeightChanged: fh -> {
					if (!fh && el.layout.fillHeight)
						fillHeight(el);
					else if (fh && !el.layout.fillHeight) {
						unfillHeight(el);
						fitHeight(el);
					}
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

		var childSlot = v -> {
			if (!v && el.visible)
				add(el);
			else if (v && !el.visible)
				remove(el);
		}
		el.onVisibleChanged(childSlot);
		el.onParentChanged(_ -> el.offVisibleChanged(childSlot));
	}

	public function remove(el:Element) {
		unfill(el);
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

	abstract function adjustWidth(alignment:Alignment, d:Float):Void;

	abstract function adjustHeight(alignment:Alignment, d:Float):Void;

	public function fit(el:Element) {
		if (!el.layout.fillWidth)
			fitWidth(el);
		if (!el.layout.fillHeight)
			fitHeight(el);
	}

	public function fitWidth(el:Element) {
		var l = left.position + left.padding + el.left.margin;
		var r = right.position - right.padding - el.right.margin - el.width;

		if (el.layout.alignment & AlignRight != 0)
			el.left.position = r;
		else if (el.layout.alignment & AlignHCenter != 0)
			el.left.position = (l + r) * 0.5;
		else
			el.left.position = l;

		el.right.position = el.left.position + el.width;
	}

	public function fitHeight(el:Element) {
		var t = top.position + top.padding + el.top.margin;
		var b = bottom.position - bottom.padding - el.bottom.margin - el.height;

		if (el.layout.alignment & AlignBottom != 0)
			el.top.position = b;
		else if (el.layout.alignment & AlignVCenter != 0)
			el.top.position = (t + b) * 0.5;
		else
			el.top.position = t;

		el.bottom.position = el.top.position + el.height;
	}

	public function fill(el:Element) {
		if (el.layout.fillWidth)
			fillWidth(el);
		if (el.layout.fillHeight)
			fillHeight(el);
	}

	public function unfill(el:Element) {
		if (el.layout.fillWidth)
			unfillWidth(el);
		if (el.layout.fillHeight)
			unfillHeight(el);
	}

	public function fillWidth(el:Element) {
		left.bind(el.left);
		right.bind(el.right);
	}

	public function fillHeight(el:Element) {
		top.bind(el.top);
		bottom.bind(el.bottom);
	}

	public function unfillWidth(el:Element) {
		left.unbind(el.left);
		right.unbind(el.right);
	}

	public function unfillHeight(el:Element) {
		top.unbind(el.top);
		bottom.unbind(el.bottom);
	}
}

#if !macro
@:build(se.macro.SMacro.build())
#end
class SingleElementBox extends Box {
	var dirtyWidthSlot:Float->Void;
	var dirtyHeightSlot:Float->Void;

	public var element:Element;
	public var slots:ElementSlots;
	@track public var availableWidth:Float = 0.0;
	@track public var availableHeight:Float = 0.0;

	public function new(el:Element, left:AnchorLine, top:AnchorLine, right:AnchorLine, bottom:AnchorLine) {
		super(left, top, right, bottom);
		element = el;
		dirtyWidthSlot = (_:Float) -> updateAvaialableWidth();
		dirtyHeightSlot = (_:Float) -> updateAvaialableHeight();

		if (element.visible)
			add(element);
	}

	function addElementSlots(el:Element, slots:ElementSlots) {
		el.onWidthChanged(dirtyWidthSlot);
		el.layout.onMinimumWidthChanged(dirtyWidthSlot);
		el.layout.onMaximumWidthChanged(dirtyWidthSlot);
		el.layout.onPreferredWidthChanged(dirtyWidthSlot);
		el.onHeightChanged(dirtyHeightSlot);
		el.layout.onMinimumHeightChanged(dirtyHeightSlot);
		el.layout.onMaximumHeightChanged(dirtyHeightSlot);
		el.layout.onPreferredHeightChanged(dirtyHeightSlot);
		this.slots = slots;
	}

	function removeElementSlots(el:Element):ElementSlots {
		el.offWidthChanged(dirtyWidthSlot);
		el.layout.offMinimumWidthChanged(dirtyWidthSlot);
		el.layout.offMaximumWidthChanged(dirtyWidthSlot);
		el.layout.offPreferredWidthChanged(dirtyWidthSlot);
		el.offHeightChanged(dirtyWidthSlot);
		el.layout.offMinimumHeightChanged(dirtyHeightSlot);
		el.layout.offMaximumHeightChanged(dirtyHeightSlot);
		el.layout.offPreferredHeightChanged(dirtyHeightSlot);
		return slots;
	}

	function updateAvaialableWidth() {
		if (!element.layout.fillWidth)
			availableWidth = right.position - left.position - getPreferredWidth();
		else
			availableWidth = 0.0;
	}

	function updateAvaialableHeight() {
		if (!element.layout.fillHeight)
			availableHeight = bottom.position - top.position - getPreferredHeight();
		else
			availableHeight = 0.0;
	}

	public function getPreferredWidth(?preferred:Float) {
		if (element.layout.fillWidth)
			return preferred == null ? null : clampWidth(preferred);
		var l = element.layout;
		var cellWidth = Math.isNaN(l.preferredWidth) ? element.width : l.preferredWidth;
		return clampWidth(cellWidth);
	}

	public function getPreferredHeight(?preferred:Float) {
		if (element.layout.fillHeight)
			return preferred == null ? null : clampHeight(preferred);
		var l = element.layout;
		var cellHeight = Math.isNaN(l.preferredHeight) ? element.height : l.preferredHeight;
		return clampHeight(cellHeight);
	}

	public function clampWidth(width:Float) {
		var l = element.layout;
		return element.left.margin + clamp(width, l.minimumWidth, l.maximumWidth) + element.right.margin;
	}

	public function clampHeight(height:Float) {
		var l = element.layout;
		return element.top.margin + clamp(height, l.minimumHeight, l.maximumHeight) + element.bottom.margin;
	}

	function adjustWidth(alignment:Alignment, d:Float) {
		Box.adjustElementWidth(element, alignment, d);
	}

	function adjustHeight(alignment:Alignment, d:Float) {
		Box.adjustElementHeight(element, alignment, d);
	}
}

class MultiElementBox extends Box {
	var elements:Map<Element, ElementSlots> = [];

	function addElementSlots(el:Element, slots:ElementSlots) {
		elements.set(el, slots);
	}

	function removeElementSlots(el:Element):ElementSlots {
		var slots = elements.get(el);
		elements.remove(el);
		return slots;
	}

	function adjustWidth(alignment:Alignment, d:Float) {
		for (c in elements.keys())
			Box.adjustElementWidth(c, alignment, d);
	}

	function adjustHeight(alignment:Alignment, d:Float) {
		for (c in elements.keys())
			Box.adjustElementHeight(c, alignment, d);
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
