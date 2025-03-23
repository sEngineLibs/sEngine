package s2d.elements.layouts;

import s2d.Box.MultiElementBox;

class BoxLayout extends Element {
	var cell:MultiElementBox;

	public function new(?parent:Element) {
		super(parent);
		cell = new MultiElementBox(left, top, right, bottom);
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
}
