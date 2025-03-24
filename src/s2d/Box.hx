package s2d;

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
						fillH(el);
					else if (fw && !el.layout.fillWidth) {
						unfillH(el);
						fitH(el);
					}
				},
				fillHeightChanged: fh -> {
					if (!fh && el.layout.fillHeight)
						fillV(el);
					else if (fh && !el.layout.fillHeight) {
						unfillV(el);
						fitV(el);
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
			fitH(el);
		if (!el.layout.fillHeight)
			fitV(el);
	}

	public function fitH(el:Element) {
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

	public function fitV(el:Element) {
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
			fillH(el);
		if (el.layout.fillHeight)
			fillV(el);
	}

	public function unfill(el:Element) {
		if (el.layout.fillWidth)
			unfillH(el);
		if (el.layout.fillHeight)
			unfillV(el);
	}

	public function fillH(el:Element) {
		left.bind(el.left);
		right.bind(el.right);
	}

	public function fillV(el:Element) {
		top.bind(el.top);
		bottom.bind(el.bottom);
	}

	public function unfillH(el:Element) {
		left.unbind(el.left);
		right.unbind(el.right);
	}

	public function unfillV(el:Element) {
		top.unbind(el.top);
		bottom.unbind(el.bottom);
	}
}

#if !macro
@:build(se.macro.SMacro.build())
#end
class SingleElementBox extends Box {
	var dirtyWidthSlot:Float->Void;
	var dirtyLayoutWidthSlot:Float->Void;
	var dirtyHeightSlot:Float->Void;
	var dirtyLayoutHeightSlot:Float->Void;

	public var element:Element;
	public var slots:ElementSlots;

	@track.single public var requiredWidth:Float;
	@track.single public var requiredHeight:Float;

	@alias public var fillWidth:Bool = element.layout.fillWidth;
	@alias public var minimumWidth:Float = element.layout.minimumWidth;
	@alias public var maximumWidth:Float = element.layout.maximumWidth;
	@alias public var preferredWidth:Float = element.layout.preferredWidth;
	@alias public var fillHeight:Bool = element.layout.fillHeight;
	@alias public var minimumHeight:Float = element.layout.minimumHeight;
	@alias public var maximumHeight:Float = element.layout.maximumHeight;
	@alias public var preferredHeight:Float = element.layout.preferredHeight;

	public function new(el:Element, left:AnchorLine, top:AnchorLine, right:AnchorLine, bottom:AnchorLine) {
		super(left, top, right, bottom);
		element = el;
		dirtyWidthSlot = (v:Float) -> if (!fillWidth) syncRequiredWidth();
		dirtyLayoutWidthSlot = (v:Float) -> syncRequiredWidth();
		dirtyHeightSlot = (v:Float) -> if (!fillHeight) syncRequiredHeight();
		dirtyLayoutHeightSlot = (v:Float) -> syncRequiredHeight();

		if (element.visible)
			add(element);
	}

	override function add(el:Element) {
		syncRequiredWidth();
		syncRequiredHeight();
		return super.add(el);
	}

	function addElementSlots(el:Element, slots:ElementSlots) {
		el.onWidthChanged(dirtyWidthSlot);
		el.layout.onMinimumWidthChanged(dirtyLayoutWidthSlot);
		el.layout.onMaximumWidthChanged(dirtyLayoutWidthSlot);
		el.layout.onPreferredWidthChanged(dirtyLayoutWidthSlot);
		el.onHeightChanged(dirtyHeightSlot);
		el.layout.onMinimumHeightChanged(dirtyLayoutHeightSlot);
		el.layout.onMaximumHeightChanged(dirtyLayoutHeightSlot);
		el.layout.onPreferredHeightChanged(dirtyLayoutHeightSlot);
		this.slots = slots;
	}

	function removeElementSlots(el:Element):ElementSlots {
		el.offWidthChanged(dirtyWidthSlot);
		el.layout.offMinimumWidthChanged(dirtyLayoutWidthSlot);
		el.layout.offMaximumWidthChanged(dirtyLayoutWidthSlot);
		el.layout.offPreferredWidthChanged(dirtyLayoutWidthSlot);
		el.offHeightChanged(dirtyHeightSlot);
		el.layout.offMinimumHeightChanged(dirtyLayoutHeightSlot);
		el.layout.offMaximumHeightChanged(dirtyLayoutHeightSlot);
		el.layout.offPreferredHeightChanged(dirtyLayoutHeightSlot);
		return this.slots;
	}

	public function syncRequiredWidth() {
		if (!Math.isNaN(preferredWidth))
			requiredWidth = clampWidth(preferredWidth);
		else if (!fillWidth)
			requiredWidth = clampWidth(element.width);
		else
			requiredWidth = 0.0;
	}

	public function syncRequiredHeight() {
		if (!Math.isNaN(preferredHeight))
			requiredHeight = clampHeight(preferredHeight);
		else if (!fillHeight)
			requiredHeight = clampHeight(element.height);
		else
			requiredHeight = 0.0;
	}

	public function clampWidth(width:Float) {
		return element.left.margin + Math.max(Math.min(width, maximumWidth), minimumWidth) + element.right.margin;
	}

	public function clampHeight(height:Float) {
		return element.top.margin + Math.max(Math.min(height, maximumHeight), minimumHeight) + element.bottom.margin;
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
