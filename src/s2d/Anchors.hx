package s2d;

import se.Log;
import s2d.Element;

class ElementAnchors {
	var el:Element;

	public var left(get, set):AnchorLineH;
	public var hCenter(get, set):AnchorLineH;
	public var right(get, set):AnchorLineH;
	public var top(get, set):AnchorLineV;
	public var vCenter(get, set):AnchorLineV;
	public var bottom(get, set):AnchorLineV;

	public var margins(never, set):Float;

	public function new(el:Element) {
		this.el = el;
	}

	public function clear() {
		unfill();
		hCenter = null;
		vCenter = null;
	}

	overload extern public inline function fill(left:AnchorLineH, right:AnchorLineH, top:AnchorLineV, bottom:AnchorLineV) {
		fillWidth(left, right);
		fillHeight(top, bottom);
	}

	overload extern public inline function fill(element:Element) {
		fill(element.left, element.right, element.top, element.bottom);
	}

	overload extern public inline function fillWidth(left:AnchorLineH, right:AnchorLineH) {
		this.left = left;
		this.right = right;
	}

	overload extern public inline function fillWidth(element:Element) {
		fillWidth(element.left, element.right);
	}

	overload extern public inline function fillHeight(top:AnchorLineV, bottom:AnchorLineV) {
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

	overload extern public inline function centerIn(hCenter:AnchorLineH, vCenter:AnchorLineV) {
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

	function bindH(ela:AnchorLineH, a:AnchorLineH) @:privateAccess {
		final el_x = el.x;
		final el_width = el.width;
		ela.bindTo(a);
		if (el.anchoring != 0) {
			el.anchoring = 0;
			ela.unbindFrom();
			el.x = el_x;
			el.width = el_width;
		}
	}

	function bindV(ea:AnchorLineV, a:AnchorLineV) @:privateAccess {
		final el_y = el.y;
		final el_height = el.height;
		ea.bindTo(a);
		if (el.anchoring != 0) {
			el.anchoring = 0;
			ea.unbindFrom();
			el.y = el_y;
			el.height = el_height;
		}
	}

	function set_margins(value:Float) {
		setMargins(value);
		return value;
	}

	function get_left() {
		return el.left.bindedTo;
	}

	function set_left(value) {
		bindH(el.left, value);
		return left;
	}

	function get_hCenter() {
		return el.hCenter.bindedTo;
	}

	function set_hCenter(value) {
		bindH(el.hCenter, value);
		return hCenter;
	}

	function get_right() {
		return el.right.bindedTo;
	}

	function set_right(value) {
		bindH(el.right, value);
		return right;
	}

	function get_top() {
		return el.top.bindedTo;
	}

	function set_top(value) {
		bindV(el.top, value);
		return top;
	}

	function get_vCenter() {
		return el.vCenter.bindedTo;
	}

	function set_vCenter(value) {
		bindV(el.vCenter, value);
		return vCenter;
	}

	function get_bottom() {
		return el.bottom.bindedTo;
	}

	function set_bottom(value) {
		bindV(el.bottom, value);
		return bottom;
	}
}

#if !macro
@:build(se.macro.SMacro.build())
@:autoBuild(se.macro.SMacro.build())
#end
abstract class AnchorLine<A:AnchorLine<A>> {
	var lines:Array<A> = [];
	var updating:Bool = false;
	var _position:Float = 0.0;

	@:isVar public var bindedTo(default, set):A = null;
	public var isBinded(get, never):Bool;

	@track public var position(get, set):Float;
	@track public var padding(default, set):Float = 0.0;
	@track public var margin(default, set):Float = 0.0;

	public function new(?position:Float) {
		if (position != null)
			this.position = position;
	}

	public function bind(line:A) {
		line.bindTo(cast this);
	}

	public function unbind(line:A) {
		if (lines.contains(line))
			line.unbindFrom();
	}

	public function bindTo(line:A) {
		bindedTo = line;
	}

	public function unbindFrom() {
		bindedTo = null;
	}

	public function hasLoop(anchor:A):Bool {
		var a = anchor;
		while (a != null) {
			if (anchor == this)
				return true;
			a = a.bindedTo;
		}
		return false;
	}

	function session(f:Void->Void) {
		updating = true;
		f();
		updating = false;
	}

	function adjust(d:Float) {
		_position += d;
		session(() -> {
			for (l in lines)
				l.position += d;
		});
	}

	abstract function syncOffset(d:Float):Void;

	function get_isBinded() {
		return bindedTo != null;
	}

	function set_bindedTo(value:A):A {
		if (value != bindedTo && !hasLoop(value)) {
			var offset = 0.0;
			if (isBinded) {
				bindedTo.lines.remove(cast this);
				offset -= bindedTo.padding + margin;
			}
			if (value != null) {
				value.lines.push(cast this);
				position = value.position;
				offset += value.padding + margin;
			}
			bindedTo = value;
			if (isBinded)
				bindedTo.session(() -> syncOffset(offset));
			else
				syncOffset(offset);
		} else
			Log.warning("Anchor binding loop detected!");
		return bindedTo;
	}

	function get_position():Float {
		return _position;
	}

	function set_position(value:Float):Float {
		if (!isBinded || bindedTo.updating)
			adjust(value - position);
		return value;
	}

	function set_padding(value:Float):Float {
		final d = value - padding;
		padding = value;
		for (line in lines)
			line.syncOffset(d);
		return padding;
	}

	function set_margin(value:Float):Float {
		final d = value - margin;
		margin = value;
		syncOffset(d);
		return margin;
	}
}

abstract class AnchorLineH extends AnchorLine<AnchorLineH> {}

class AnchorLineH_S extends AnchorLineH {
	function syncOffset(d:Float) {
		position += d;
	}
}

class AnchorLineH_E extends AnchorLineH {
	function syncOffset(d:Float) {
		position -= d;
	}
}

abstract class AnchorLineV extends AnchorLine<AnchorLineV> {}

class AnchorLineV_S extends AnchorLineV {
	function syncOffset(d:Float) {
		position += d;
	}
}

class AnchorLineV_E extends AnchorLineV {
	function syncOffset(d:Float) {
		position -= d;
	}
}
