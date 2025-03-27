package s2d.elements.layouts;

import s2d.Alignment;

class BoxLayout extends Element {
	var slots:Map<Element, LayoutSlots> = [];

	public function new() {
		super();
	}

	override function __childAdded__(child:Element) {
		slots.set(child, {
			fillWidthChanged: fw -> {
				if (!fw && child.layout.fillWidth)
					child.anchors.fillWidth(this);
				else if (fw && !child.layout.fillWidth) {
					child.anchors.unfillWidth();
					fitH(child);
				}
			},
			fillHeightChanged: fh -> {
				if (!fh && child.layout.fillHeight)
					child.anchors.fillHeight(this);
				else if (fh && !child.layout.fillHeight) {
					child.anchors.unfillHeight();
					fitV(child);
				}
			},
			alignmentChanged: a -> {
				child.anchors.clear();
				if (child.layout.fillWidth)
					child.anchors.fillWidth(this);
				else
					fitH(child);
				if (child.layout.fillHeight)
					child.anchors.fillHeight(this);
				else
					fitV(child);
			}
		});
		super.__childAdded__(child);
	}

	override function __childRemoved__(child:Element) {
		super.__childRemoved__(child);
		slots.remove(child);
	}

	@:slot(vChildAdded)
	function track(child:Element) {
		fit(child);
		var childSlots = slots.get(child);
		child.layout.onFillWidthChanged(childSlots.fillWidthChanged);
		child.layout.onFillHeightChanged(childSlots.fillHeightChanged);
		child.layout.onAlignmentChanged(childSlots.alignmentChanged);
	}

	@:slot(vChildRemoved)
	function untrack(child:Element) {
		var childSlots = slots.get(child);
		child.layout.offFillWidthChanged(childSlots.fillWidthChanged);
		child.layout.offFillHeightChanged(childSlots.fillHeightChanged);
		child.layout.offAlignmentChanged(childSlots.alignmentChanged);
	}

	function fit(el:Element) {
		fitH(el);
		fitV(el);
	}

	function fitH(el:Element) {
		final a = el.layout.alignment;
		if (a & AlignRight != 0)
			el.anchors.right = right;
		else if (a & AlignHCenter != 0)
			el.anchors.hCenter = hCenter;
		else
			el.anchors.left = left;
	}

	function fitV(el:Element) {
		final a = el.layout.alignment;
		if (a & AlignBottom != 0)
			el.anchors.bottom = bottom;
		else if (a & AlignVCenter != 0)
			el.anchors.vCenter = vCenter;
		else
			el.anchors.top = top;
	}
}

private typedef LayoutSlots = {
	fillWidthChanged:Bool->Void,
	fillHeightChanged:Bool->Void,
	alignmentChanged:Float->Void
}
