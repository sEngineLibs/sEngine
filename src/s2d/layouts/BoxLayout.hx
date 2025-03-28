package s2d.layouts;

import s2d.Alignment;

class BoxLayout extends Element {
	var slots:Map<Element, {
		fillWidthChanged:Bool->Void,
		fillHeightChanged:Bool->Void,
		alignmentChanged:Float->Void
	}> = [];

	public function new(?scene:WindowScene) {
		super(scene);
	}

	override function __childAdded__(child:Element) {
		slots.set(child, {
			alignmentChanged: a -> fit(child),
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
			}
		});
		super.__childAdded__(child);
	}

	override function __childRemoved__(child:Element) {
		super.__childRemoved__(child);
		slots.remove(child);
		child.anchors.clear();
	}

	@:slot(vChildAdded)
	function add(child:Element) {
		fit(child);
		var childSlots = slots.get(child);
		child.layout.onFillWidthChanged(childSlots.fillWidthChanged);
		child.layout.onFillHeightChanged(childSlots.fillHeightChanged);
		child.layout.onAlignmentChanged(childSlots.alignmentChanged);
	}

	@:slot(vChildRemoved)
	function remove(child:Element) {
		var childSlots = slots.get(child);
		child.anchors.clear();
		child.layout.offFillWidthChanged(childSlots.fillWidthChanged);
		child.layout.offFillHeightChanged(childSlots.fillHeightChanged);
		child.layout.offAlignmentChanged(childSlots.alignmentChanged);
	}

	function fit(el:Element) {
		el.anchors.clear();
		if (el.layout.fillWidth)
			el.anchors.fillWidth(this);
		else
			fitH(el);
		if (el.layout.fillHeight)
			el.anchors.fillHeight(this);
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
}
