package s2d.ui;

import s2d.ui.UIElement;

abstract Anchors(UIElement) from UIElement {
	public var left(get, set):AnchorLine;
	public var top(get, set):AnchorLine;
	public var right(get, set):AnchorLine;
	public var bottom(get, set):AnchorLine;
	public var margins(never, set):Float;

	extern public inline function fill(element:UIElement) {
		fillWidth(element);
		fillHeight(element);
	}

	extern public inline function unfill() {
		unfillWidth();
		unfillHeight();
	}

	extern public inline function fillWidth(element:UIElement) {
		this.left.bindTo(element.left);
		this.right.bindTo(element.right);
	}

	extern public inline function unfillWidth() {
		this.left.unbindFrom();
		this.right.unbindFrom();
	}

	extern public inline function fillHeight(element:UIElement) {
		this.top.bindTo(element.top);
		this.bottom.bindTo(element.bottom);
	}

	extern public inline function unfillHeight() {
		this.top.unbindFrom();
		this.bottom.unbindFrom();
	}

	extern public inline function setMargins(value:Float):Void {
		margins = value;
	}

	extern inline function set_margins(value:Float) {
		this.left.margin = value;
		this.top.margin = value;
		this.right.margin = value;
		this.bottom.margin = value;
		return value;
	}

	extern inline function get_left():AnchorLine {
		return this.left.bindedTo;
	}

	extern inline function set_left(value:AnchorLine):AnchorLine {
		this.left.bindTo(value);
		return value;
	}

	extern inline function get_top():AnchorLine {
		return this.top.bindedTo;
	}

	extern inline function set_top(value:AnchorLine):AnchorLine {
		this.top.bindTo(value);
		return value;
	}

	extern inline function get_right():AnchorLine {
		return this.right.bindedTo;
	}

	extern inline function set_right(value:AnchorLine):AnchorLine {
		this.right.bindTo(value);
		return value;
	}

	extern inline function get_bottom():AnchorLine {
		return this.bottom.bindedTo;
	}

	extern inline function set_bottom(value:AnchorLine):AnchorLine {
		this.bottom.bindTo(value);
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
