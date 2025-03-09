package s2d;

import s2d.Element;

abstract Anchors(Element) from Element {
	public var left(get, set):AnchorLine;
	public var top(get, set):AnchorLine;
	public var right(get, set):AnchorLine;
	public var bottom(get, set):AnchorLine;
	public var margins(never, set):Float;

	public inline function fill(element:Element) {
		fillWidth(element);
		fillHeight(element);
	}

	public inline function unfill() {
		unfillWidth();
		unfillHeight();
	}

	public inline function fillWidth(element:Element) {
		this.left.bindTo(element.left);
		this.right.bindTo(element.right);
	}

	public inline function unfillWidth() {
		this.left.unbindFrom();
		this.right.unbindFrom();
	}

	public inline function fillHeight(element:Element) {
		this.top.bindTo(element.top);
		this.bottom.bindTo(element.bottom);
	}

	public inline function unfillHeight() {
		this.top.unbindFrom();
		this.bottom.unbindFrom();
	}

	public inline function setMargins(value:Float):Void {
		margins = value;
	}

	private inline function set_margins(value:Float) {
		this.left.margin = value;
		this.top.margin = value;
		this.right.margin = value;
		this.bottom.margin = value;
		return value;
	}

	private inline function get_left():AnchorLine {
		return this.left.bindedTo;
	}

	private inline function set_left(value:AnchorLine):AnchorLine {
		this.left.bindTo(value);
		return value;
	}

	private inline function get_top():AnchorLine {
		return this.top.bindedTo;
	}

	private inline function set_top(value:AnchorLine):AnchorLine {
		this.top.bindTo(value);
		return value;
	}

	private inline function get_right():AnchorLine {
		return this.right.bindedTo;
	}

	private inline function set_right(value:AnchorLine):AnchorLine {
		this.right.bindTo(value);
		return value;
	}

	private inline function get_bottom():AnchorLine {
		return this.bottom.bindedTo;
	}

	private inline function set_bottom(value:AnchorLine):AnchorLine {
		this.bottom.bindTo(value);
		return value;
	}
}

@:forward.new
abstract AnchorLine(AnchorLineData) from AnchorLineData to AnchorLineData {
	public var bindedTo(get, set):AnchorLine;
	public var isBinded(get, never):Bool;

	public var position(get, set):Float;
	public var margin(get, set):Float;
	public var padding(get, set):Float;

	public inline function bind(value:AnchorLineData) {
		value.bindedTo = this;
		value.position = value.margin + position + padding * this.m;
		this.binded.push(value);
	}

	public inline function unbind(value:AnchorLineData) {
		value.bindedTo = null;
		this.binded.remove(value);
	}

	public inline function bindTo(value:AnchorLine) {
		value.bind(this);
	}

	public inline function unbindFrom() {
		bindedTo.unbind(this);
	}

	private inline function get_bindedTo():AnchorLine {
		return this.bindedTo;
	}

	private inline function set_bindedTo(value:AnchorLine):AnchorLine {
		if (value != null)
			value.bind(this);
		else if (isBinded)
			bindedTo.unbind(this);
		return value;
	}

	private inline function get_position():Float {
		return this.position;
	}

	private inline function set_position(value:Float) {
		if (!isBinded) {
			final d = value - position;
			this.position = value;
			for (b in this.binded)
				b.position += d;
		}
		return value;
	}

	private inline function get_isBinded() {
		return bindedTo != null;
	}

	private inline function get_margin():Float {
		return this.margin;
	}

	private inline function set_margin(value:Float) {
		this.margin = value;
		if (bindedTo != null)
			position = bindedTo.position + (bindedTo.padding + margin) * this.m;
		return value;
	}

	private inline function get_padding():Float {
		return this.padding;
	}

	private inline function set_padding(value:Float) {
		final d = value * this.m - padding;
		this.padding = value;
		for (b in this.binded)
			b.position += d;
		return value;
	}
}

@:allow(s2d.Anchors)
private class AnchorLineData {
	var bindedTo:AnchorLine = null;
	var binded:Array<AnchorLine> = [];

	var m:Float;
	var position:Float = 0.0;
	var margin:Float = 0.0;
	var padding:Float = 0.0;

	public inline function new(m:Float) {
		this.m = m;
	}
}
