package s2d.anchors;

import s2d.Element;
import s2d.anchors.AnchorLine;

class Anchors {
	var el:Element;

	public var left(get, set):AnchorLineHorizontal;
	public var top(get, set):AnchorLineVertical;
	public var right(get, set):AnchorLineHorizontal;
	public var bottom(get, set):AnchorLineVertical;
	public var hCenter(get, set):AnchorLineHorizontal;
	public var vCenter(get, set):AnchorLineVertical;
	public var margins(never, set):Float;

	public function new(el:Element) {
		this.el = el;
	}

	public function clear() {
		unfill();
		hCenter = null;
		vCenter = null;
	}

	overload extern public inline function fill(left:AnchorLineHorizontal, right:AnchorLineHorizontal, top:AnchorLineVertical, bottom:AnchorLineVertical) {
		fillWidth(left, right);
		fillHeight(top, bottom);
	}

	overload extern public inline function fill(element:Element) {
		fill(element.left, element.right, element.top, element.bottom);
	}

	overload extern public inline function fillWidth(left:AnchorLineHorizontal, right:AnchorLineHorizontal) {
		this.left = left;
		this.right = right;
	}

	overload extern public inline function fillWidth(element:Element) {
		fillWidth(element.left, element.right);
	}

	overload extern public inline function fillHeight(top:AnchorLineVertical, bottom:AnchorLineVertical) {
		this.top = top;
		this.bottom = bottom;
	}

	overload extern public inline function fillHeight(element:Element) {
		fillHeight(element.top, element.bottom);
	}

	overload extern public inline function unfill() {
		unfillWidth();
		unfillHeight();
	}

	overload extern public inline function unfillWidth() {
		left = null;
		right = null;
	}

	overload extern public inline function unfillHeight() {
		top = null;
		bottom = null;
	}

	overload extern public inline function centerIn(hCenter:AnchorLineHorizontal, vCenter:AnchorLineVertical) {
		this.hCenter = hCenter;
		this.vCenter = vCenter;
	}

	overload extern public inline function centerIn(element:Element) {
		centerIn(element.hCenter, element.vCenter);
	}

	overload extern public inline function setMargins(left:Float, top:Float, right:Float, bottom:Float):Void {
		this.left.margin = left;
		this.top.margin = top;
		this.right.margin = right;
		this.bottom.margin = bottom;
	}

	overload extern public inline function setMargins(value:Float):Void {
		setMargins(value, value, value, value);
	}

	function set_margins(value:Float) {
		setMargins(value);
		return value;
	}

	function get_left() {
		return el.left.bindedTo;
	}

	function set_left(value) {
		el.left.bindTo(value);
		return left;
	}

	function get_top() {
		return el.top.bindedTo;
	}

	function set_top(value) {
		el.top.bindTo(value);
		return top;
	}

	function get_right() {
		return el.right.bindedTo;
	}

	function set_right(value) {
		el.right.bindTo(value);
		return right;
	}

	function get_bottom() {
		return el.bottom.bindedTo;
	}

	function set_bottom(value) {
		el.bottom.bindTo(value);
		return bottom;
	}

	function get_hCenter() {
		return el.hCenter.bindedTo;
	}

	function set_hCenter(value) {
		el.hCenter.bindTo(value);
		return hCenter;
	}

	function get_vCenter() {
		return el.vCenter.bindedTo;
	}

	function set_vCenter(value) {
		el.vCenter.bindTo(value);
		return vCenter;
	}
}

interface ElementAnchor {
	private var el:Element;

	private function syncPosition(d:Float):Void;
}

private function anchor(a:ElementAnchor, d:Float) @:privateAccess {
	a.el.anchoring = true;
	a.syncPosition(d);
	a.el.anchoring = false;
}

@:access(s2d.Element)
class AnchorLeft extends AnchorLineLeft implements ElementAnchor {
	var el:Element;

	public function new(el:Element) {
		this.el = el;
		super();
		_position = el.absX;
	}

	function syncPosition(d:Float) {
		if (!(el.right.isBinded && el.hCenter.isBinded)) {
			el.absX += d;
			if (!el.right.isBinded && !el.hCenter.isBinded) {
				el.hCenter.adjust(d);
				el.right.adjust(d);
			} else if (el.right.isBinded && !el.hCenter.isBinded) {
				el.width -= d;
				el.hCenter.adjust(d * 0.5);
			} else if (!el.right.isBinded && el.hCenter.isBinded) {
				final d2 = d * 2;
				el.width -= d2;
				el.right.adjust(-d2);
			}
			el.geometryChanged();
		}
	}

	override function set_position(value:Float):Float {
		if (!isBinded || bindedTo.updating) {
			final d = value - _position;
			anchor(this, d);
			adjust(d);
		}
		return value;
	}
}

@:access(s2d.Element)
class AnchorHCenter extends AnchorLineHCenter implements ElementAnchor {
	var el:Element;

	public function new(el:Element) {
		this.el = el;
		super();
		_position = el.absX + el.width * 0.5;
	}

	function syncPosition(d:Float) {
		if (!(el.left.isBinded && el.right.isBinded)) {
			if (!el.left.isBinded && !el.right.isBinded) {
				el.absX += d;
				el.left.adjust(d);
				el.right.adjust(d);
			} else if (el.left.isBinded && !el.right.isBinded) {
				final d2 = d * 2;
				el.width += d2;
				el.right.adjust(d2);
			} else if (!el.left.isBinded && el.right.isBinded) {
				final d2 = d * 2;
				el.absX += d2;
				el.width -= d2;
				el.left.adjust(d2);
			}
			el.geometryChanged();
		}
	}

	override function set_position(value:Float):Float {
		if (!isBinded || bindedTo.updating) {
			final d = value - _position;
			anchor(this, d);
			adjust(d);
		}
		return value;
	}
}

@:access(s2d.Element)
class AnchorRight extends AnchorLineRight implements ElementAnchor {
	var el:Element;

	public function new(el:Element) {
		this.el = el;
		super();
		_position = el.absX + el.width;
	}

	function syncPosition(d:Float) {
		if (!(el.left.isBinded && el.hCenter.isBinded)) {
			if (!el.left.isBinded && !el.hCenter.isBinded) {
				el.absX += d;
				el.left.adjust(d);
				el.hCenter.adjust(d);
			} else if (el.left.isBinded && !el.hCenter.isBinded) {
				el.width += d;
				el.hCenter.adjust(d * 0.5);
			} else if (!el.left.isBinded && el.hCenter.isBinded) {
				el.absX -= d;
				el.width += d * 2;
				el.left.adjust(-d);
			}
			el.geometryChanged();
		}
	}

	override function set_position(value:Float):Float {
		if (!isBinded || bindedTo.updating) {
			final d = value - _position;
			anchor(this, d);
			adjust(d);
		}
		return value;
	}
}

@:access(s2d.Element)
class AnchorTop extends AnchorLineTop implements ElementAnchor {
	var el:Element;

	public function new(el:Element) {
		this.el = el;
		super();
		_position = el.absY;
	}

	function syncPosition(d:Float) {
		if (!(el.bottom.isBinded && el.vCenter.isBinded)) {
			el.absY += d;
			if (!el.bottom.isBinded && !el.vCenter.isBinded) {
				el.vCenter.adjust(d);
				el.bottom.adjust(d);
			} else if (el.bottom.isBinded && !el.vCenter.isBinded) {
				el.height -= d;
				el.vCenter.adjust(d * 0.5);
			} else if (!el.bottom.isBinded && el.vCenter.isBinded) {
				final d2 = d * 2;
				el.height -= d2;
				el.bottom.adjust(-d2);
			}
			el.geometryChanged();
		}
	}

	override function set_position(value:Float):Float {
		if (!isBinded || bindedTo.updating) {
			final d = value - _position;
			anchor(this, d);
			adjust(d);
		}
		return value;
	}
}

@:access(s2d.Element)
class AnchorVCenter extends AnchorLineVCenter implements ElementAnchor {
	var el:Element;

	public function new(el:Element) {
		this.el = el;
		super();
		_position = el.absY + el.height * 0.5;
	}

	function syncPosition(d:Float) {
		if (!(el.top.isBinded && el.bottom.isBinded)) {
			if (!el.top.isBinded && !el.bottom.isBinded) {
				el.absY += d;
				el.top.adjust(d);
				el.bottom.adjust(d);
			} else if (el.top.isBinded && !el.bottom.isBinded) {
				final d2 = d * 2;
				el.height += d2;
				el.bottom.adjust(d2);
			} else if (!el.top.isBinded && el.bottom.isBinded) {
				final d2 = d * 2;
				el.absY += d2;
				el.height -= d2;
				el.top.adjust(d2);
			}
			el.geometryChanged();
		}
	}

	override function set_position(value:Float):Float {
		if (!isBinded || bindedTo.updating) {
			final d = value - _position;
			anchor(this, d);
			adjust(d);
		}
		return value;
	}
}

@:access(s2d.Element)
class AnchorBottom extends AnchorLineBottom implements ElementAnchor {
	var el:Element;

	public function new(el:Element) {
		this.el = el;
		super();
		_position = el.absY + el.height;
	}

	function syncPosition(d:Float) {
		if (!(el.top.isBinded && el.vCenter.isBinded)) {
			if (!el.top.isBinded && !el.vCenter.isBinded) {
				el.absY += d;
				el.top.adjust(d);
				el.vCenter.adjust(d);
			} else if (el.top.isBinded && !el.vCenter.isBinded) {
				el.height += d;
				el.vCenter.adjust(d * 0.5);
			} else if (!el.top.isBinded && el.vCenter.isBinded) {
				el.absY -= d;
				el.height += d * 2;
				el.top.adjust(-d);
			}
			el.geometryChanged();
		}
	}

	override function set_position(value:Float):Float {
		if (!isBinded || bindedTo.updating) {
			final d = value - _position;
			anchor(this, d);
			adjust(d);
		}
		return value;
	}
}
