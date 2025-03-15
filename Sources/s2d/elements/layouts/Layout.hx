package s2d.elements.layouts;

import s2d.Alignment;

class Layout extends Element {
	var slots:Map<Element, Void->Void> = [];

	public function new(?parent:Element) {
		super(parent);
	}

	override function childAdded(child:Element):Void {
		var slot = () -> {
			if (child.layout.alignment & AlignLeft != 0)
				child.x = left.padding + child.left.margin;
			if (child.layout.alignment & AlignRight != 0)
				child.x = right.position - right.padding - child.width;
			if (child.layout.alignment & AlignHCenter != 0)
				child.x = left.padding + (right.position - child.width) / 2 - right.padding;
			if (child.layout.alignment & AlignTop != 0)
				child.y = top.padding + child.top.margin;
			if (child.layout.alignment & AlignBottom != 0)
				child.y = bottom.position - bottom.padding - child.height;
			if (child.layout.alignment & AlignVCenter != 0)
				child.y = top.padding + (bottom.position - child.height) / 2 - bottom.padding;
		};
		slots.set(child, slot);
		child.layout.onDirty(slot);
	}

	override function childRemoved(child:Element):Void {
		child.layout.offDirty(slots.get(child));
		slots.remove(child);
	}

	@:slot(widthChanged)
	function _widthChanged(v:Float) {
		update(AlignRight, AlignHCenter, width - v);
	}

	@:slot(heightChanged)
	function _heightChanged(v:Float) {
		update(AlignBottom, AlignVCenter, height - v);
	}

	@:slot(left.paddingChanged)
	function _leftPaddingChanged(v:Float) {
		update(AlignLeft, AlignHCenter, left.padding - v);
	}

	@:slot(top.paddingChanged)
	function _topPaddingChanged(v:Float) {
		update(AlignTop, AlignVCenter, top.padding - v);
	}

	@:slot(right.paddingChanged)
	function _rightPaddingChanged(v:Float) {
		update(AlignRight, AlignHCenter, v - right.padding);
	}

	@:slot(bottom.paddingChanged)
	function _bottomPaddingChanged(v:Float) {
		update(AlignBottom, AlignVCenter, v - bottom.padding);
	}

	function update(a:Alignment, a2:Alignment, d:Float) {
		final d2 = d / 2;
		for (c in children) {
			if (c.layout.alignment & a != 0)
				c.x += d;
			else if (c.layout.alignment & a2 != 0)
				c.x += d2;
		}
	}
}
