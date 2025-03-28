package s2d.elements.layouts;

import s2d.Anchors;
import s2d.Alignment;

#if !macro
@:build(se.macro.SMacro.build())
#end
@:dox(hide)
class LayoutCell {
	var dirtyWidthSlot:Float->Void;
	var dirtyLayoutWidthSlot:Float->Void;
	var dirtyHeightSlot:Float->Void;
	var dirtyLayoutHeightSlot:Float->Void;

	public var element:Element;
	public var slots:ElementSlots;

	public var left:AnchorLineH;
	public var hCenter:AnchorLineH;
	public var right:AnchorLineH;
	public var top:AnchorLineV;
	public var vCenter:AnchorLineV;
	public var bottom:AnchorLineV;

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

	public function new(el:Element, left:AnchorLineH, top:AnchorLineV, right:AnchorLineH, bottom:AnchorLineV) {
		element = el;
		this.left = left;
		this.top = top;
		this.right = right;
		this.bottom = bottom;
		hCenter = new AnchorLineH_S(left.position + right.position * 0.5);
		vCenter = new AnchorLineV_E(top.position + bottom.position * 0.5);

		dirtyWidthSlot = (v:Float) -> if (!fillWidth) syncRequiredWidth();
		dirtyLayoutWidthSlot = (v:Float) -> syncRequiredWidth();
		dirtyHeightSlot = (v:Float) -> if (!fillHeight) syncRequiredHeight();
		dirtyLayoutHeightSlot = (v:Float) -> syncRequiredHeight();

		add(el);
	}

	public function add(el:Element) {
		fit(el);
		slots = {
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
		};
		el.onWidthChanged(dirtyWidthSlot);
		el.onHeightChanged(dirtyHeightSlot);
		el.layout.onMinimumWidthChanged(dirtyLayoutWidthSlot);
		el.layout.onMaximumWidthChanged(dirtyLayoutWidthSlot);
		el.layout.onPreferredWidthChanged(dirtyLayoutWidthSlot);
		el.layout.onMinimumHeightChanged(dirtyLayoutHeightSlot);
		el.layout.onMaximumHeightChanged(dirtyLayoutHeightSlot);
		el.layout.onPreferredHeightChanged(dirtyLayoutHeightSlot);
		el.layout.onAlignmentChanged(slots.alignmentChanged);
		el.layout.onFillWidthChanged(slots.fillWidthChanged);
		el.layout.onFillHeightChanged(slots.fillHeightChanged);

		syncRequiredWidth();
		syncRequiredHeight();
	}

	public function remove(el:Element) {
		el.offWidthChanged(dirtyWidthSlot);
		el.offHeightChanged(dirtyHeightSlot);
		el.layout.offMinimumWidthChanged(dirtyLayoutWidthSlot);
		el.layout.offMaximumWidthChanged(dirtyLayoutWidthSlot);
		el.layout.offPreferredWidthChanged(dirtyLayoutWidthSlot);
		el.layout.offMinimumHeightChanged(dirtyLayoutHeightSlot);
		el.layout.offMaximumHeightChanged(dirtyLayoutHeightSlot);
		el.layout.offPreferredHeightChanged(dirtyLayoutHeightSlot);
		el.layout.offAlignmentChanged(slots.alignmentChanged);
		el.layout.offFillWidthChanged(slots.fillWidthChanged);
		el.layout.offFillHeightChanged(slots.fillHeightChanged);
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

	function fit(el:Element) {
		el.anchors.clear();
		if (el.layout.fillWidth)
			el.anchors.fillWidth(left, right);
		else
			fitH(el);
		if (el.layout.fillHeight)
			el.anchors.fillHeight(top, bottom);
		else
			fitV(el);
	}

	function fitH(el:Element) {
		if (el.layout.alignment & AlignRight != 0)
			el.anchors.right = right;
		else if (el.layout.alignment & AlignHCenter != 0)
			el.anchors.hCenter = hCenter;
		else
			el.anchors.left = left;
	}

	function fitV(el:Element) {
		if (el.layout.alignment & AlignBottom != 0)
			el.anchors.bottom = bottom;
		else if (el.layout.alignment & AlignVCenter != 0)
			el.anchors.vCenter = vCenter;
		else
			el.anchors.top = top;
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

private typedef ElementSlots = {
	alignmentChanged:Alignment->Void,
	fillWidthChanged:Bool->Void,
	fillHeightChanged:Bool->Void
}
