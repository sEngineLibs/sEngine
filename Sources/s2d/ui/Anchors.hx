package s2d.ui;

import s2d.ui.UIElement;

class Anchors {
	var _el:UIElement;

	public var left(get, set):AnchorLine;
	public var top(get, set):AnchorLine;
	public var right(get, set):AnchorLine;
	public var bottom(get, set):AnchorLine;
	public var margins(never, set):Float;

	public function new(element:UIElement) {
		_el = element;
	}

	public function fill(element:UIElement) {
		fillWidth(element);
		fillHeight(element);
	}

	public function unfill() {
		unfillWidth();
		unfillHeight();
	}

	public function fillWidth(element:UIElement) {
		_el.left.bindTo(element.left);
		_el.right.bindTo(element.right);
	}

	public function unfillWidth() {
		_el.left.unbindFrom();
		_el.right.unbindFrom();
	}

	public function fillHeight(element:UIElement) {
		_el.top.bindTo(element.top);
		_el.bottom.bindTo(element.bottom);
	}

	public function unfillHeight() {
		_el.top.unbindFrom();
		_el.bottom.unbindFrom();
	}

	public function setMargins(value:Float):Void {
		margins = value;
	}

	extern inline function set_margins(value:Float) {
		_el.left.margin = value;
		_el.top.margin = value;
		_el.right.margin = value;
		_el.bottom.margin = value;
		return value;
	}

	extern inline function get_left():AnchorLine {
		return _el.left.bindedTo;
	}

	extern inline function set_left(value:AnchorLine):AnchorLine {
		_el.left.bindTo(value);
		return value;
	}

	extern inline function get_top():AnchorLine {
		return _el.top.bindedTo;
	}

	extern inline function set_top(value:AnchorLine):AnchorLine {
		_el.top.bindTo(value);
		return value;
	}

	extern inline function get_right():AnchorLine {
		return _el.right.bindedTo;
	}

	extern inline function set_right(value:AnchorLine):AnchorLine {
		_el.right.bindTo(value);
		return value;
	}

	extern inline function get_bottom():AnchorLine {
		return _el.bottom.bindedTo;
	}

	extern inline function set_bottom(value:AnchorLine):AnchorLine {
		_el.bottom.bindTo(value);
		return value;
	}
}

@:allow(s2d.ui.Anchors)
class AnchorLine {
	@:isVar var m(default, null):Float;
	@:isVar var bindedTo(default, null):AnchorLine = null;
	@:isVar var binded(default, null):Array<AnchorLine> = [];

	public var isBinded(get, never):Bool;
	@:isVar public var position(default, set):Float = 0.0;
	@:isVar public var margin(default, set):Float = 0.0;
	@:isVar public var padding(default, set):Float = 0.0;

	public inline function new(m:Float) {
		this.m = m;
	}

	public inline function bind(value:AnchorLine) {
		value.bindedTo = this;
		value.position = value.margin + position + padding * m;
		binded.push(value);
	}

	public inline function unbind(value:AnchorLine) {
		value.bindedTo = null;
		binded.remove(value);
	}

	public inline function bindTo(value:AnchorLine) {
		value.bind(this);
	}

	public inline function unbindFrom() {
		bindedTo.unbind(this);
	}

	inline function set_position(value:Float) {
		final d = value - position;
		for (b in binded)
			b.position += d;
		position = value;
		return value;
	}

	extern inline function get_isBinded() {
		return bindedTo != null;
	}

	extern inline function set_margin(value:Float) {
		if (bindedTo != null)
			position = bindedTo.position + (bindedTo.padding + value) * m;
		margin = value;
		return value;
	}

	extern inline function set_padding(value:Float) {
		final d = value * m - padding;
		for (b in binded)
			b.position += d;
		padding = value;
		return value;
	}
}
