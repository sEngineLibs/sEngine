package s2d;

import s2d.Element;

extern abstract Anchors(Element) from Element {
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

	inline function set_margins(value:Float) {
		this.left.margin = value;
		this.top.margin = value;
		this.right.margin = value;
		this.bottom.margin = value;
		return value;
	}

	inline function get_left():AnchorLine {
		return this.left.bindedTo;
	}

	inline function set_left(value:AnchorLine):AnchorLine {
		this.left.bindTo(value);
		return left;
	}

	inline function get_top():AnchorLine {
		return this.top.bindedTo;
	}

	inline function set_top(value:AnchorLine):AnchorLine {
		this.top.bindTo(value);
		return top;
	}

	inline function get_right():AnchorLine {
		return this.right.bindedTo;
	}

	inline function set_right(value:AnchorLine):AnchorLine {
		this.right.bindTo(value);
		return right;
	}

	inline function get_bottom():AnchorLine {
		return this.bottom.bindedTo;
	}

	inline function set_bottom(value:AnchorLine):AnchorLine {
		this.bottom.bindTo(value);
		return bottom;
	}
}

@:allow(s2d.Anchors)
@:forward.new
@:forward(binded, bindedTo, onPositionChanged, offPositionChanged, onMarginChanged, offMarginChanged, onPaddingChanged, offPaddingChanged)
extern abstract AnchorLine(AnchorLineData) from AnchorLineData {
	public var bindedTo(get, set):AnchorLine;
	public var isBinded(get, never):Bool;

	public var position(get, set):Float;
	public var margin(get, set):Float;
	public var padding(get, set):Float;

	public inline function new(m:Float) {
		this = new AnchorLineData(m);
	}

	public inline function bind(line:AnchorLine) {
		line.bindedTo = this;
	}

	public inline function unbind(line:AnchorLine) {
		line.bindedTo = null;
	}

	public inline function bindTo(line:AnchorLine) {
		bindedTo = line;
	}

	public inline function unbindFrom() {
		bindedTo = null;
	}

	@:to
	private inline function toFloat():Float {
		return this.position;
	}

	@:op(-a)
	private inline function neg() {
		return -this.position;
	}

	@:op(a + b)
	private inline function add(b:Float) {
		return this.position + b;
	}

	@:op(a - b)
	private inline function sub(b:Float) {
		return this.position - b;
	}

	@:op(a * b)
	private inline function mul(b:Float) {
		return this.position * b;
	}

	@:op(a / b)
	private inline function div(b:Float) {
		return this.position / b;
	}

	@:op(a % b)
	private inline function mod(b:Float) {
		return this.position % b;
	}

	@:op(a += b)
	private inline function addassign(b:Float) {
		return this.position += b;
	}

	@:op(a -= b)
	private inline function subassign(b:Float) {
		return this.position -= b;
	}

	@:op(a *= b)
	private inline function mulassign(b:Float) {
		return this.position *= b;
	}

	@:op(a /= b)
	private inline function divassign(b:Float) {
		return this.position /= b;
	}

	@:op(a %= b)
	private inline function modassign(b:Float) {
		return this.position %= b;
	}

	private inline function get_bindedTo() @:privateAccess {
		return this.bindedTo;
	}

	private inline function set_bindedTo(value:AnchorLine):AnchorLine @:privateAccess {
		if (bindedTo != value) {
			if (isBinded && bindedTo.binded.contains(this)) {
				bindedTo.binded.remove(this);
				this.position = bindedTo.position;
			}
			if (value != null && !value.binded.contains(this)) {
				value.binded.push(this);
				this.position = value + this.m * (value.padding + margin);
			}
			bindedTo = value;
		}
		return bindedTo;
	}

	private inline function get_isBinded() {
		return bindedTo != null;
	}

	private inline function get_position() {
		return this.position;
	}

	private inline function set_position(value:Float) @:privateAccess {
		if (!isBinded) {
			final d = value - this.position;
			this.position = value;
			for (b in this.binded)
				b += d;
		}
		return value;
	}

	private inline function get_margin() {
		return this.margin;
	}

	private inline function set_margin(value:Float) @:privateAccess {
		value = Math.max(0.0, value);
		if (isBinded)
			this.position += (value - margin) * this.m;
		this.margin = value;
		return value;
	}

	private inline function get_padding() {
		return this.padding;
	}

	private inline function set_padding(value:Float) @:privateAccess {
		value = Math.max(0.0, value);
		final d = (padding - value) * this.m;
		this.padding = value;
		for (b in this.binded)
			b += d;
		return value;
	}
}

#if !macro
@:build(se.macro.SMacro.build())
#end
@:dox(hide)
class AnchorLineData {
	var m:Float;
	var binded:Array<AnchorLine> = [];
	var bindedTo:AnchorLine = null;

	@track public var position:Float = 0.0;
	@track public var margin:Float = 0.0;
	@track public var padding:Float = 0.0;

	public function new(m:Float) {
		this.m = m;
	}
}
