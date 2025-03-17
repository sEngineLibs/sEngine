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

#if !macro
@:build(se.macro.SMacro.build())
#end
@:allow(s2d.Anchors)
class AnchorLine {
	var m:Float;
	var binded:Array<AnchorLine> = [];
	@:isVar var bindedTo(default, set):AnchorLine = null;

	public var isBinded(get, never):Bool;
	@track public var position:Float = 0.0;
	@track public var margin:Float = 0.0;
	@track public var padding:Float = 0.0;

	public function new(m:Float) {
		this.m = m;
	}

	public function bind(line:AnchorLine) {
		line.bindedTo = this;
	}

	public function unbind(line:AnchorLine) {
		line.bindedTo = null;
	}

	public function bindTo(line:AnchorLine) {
		bindedTo = line;
	}

	public function unbindFrom() {
		bindedTo = null;
	}

	@:slot(positionChanged)
	function _positionChanged(previous:Float) {
		final d = position - previous;
		for (b in binded)
			b.position += d;
	}

	@:slot(marginChanged)
	function _marginChanged(previous:Float) {
		if (isBinded)
			position = bindedTo.position + (bindedTo.padding + margin) * m;
	}

	@:slot(positionChanged)
	function _paddingChanged(previous:Float) {
		final d = (previous - padding) * m;
		for (b in binded)
			b.position += d;
	}

	inline function set_bindedTo(line:AnchorLine):AnchorLine {
		if (bindedTo != line) {
			if (bindedTo != null && bindedTo.binded.contains(this)) {
				bindedTo.binded.remove(this);
				position = bindedTo.position;
			}
			if (line != null && !line.binded.contains(this)) {
				line.binded.push(this);
				position = line.position + m * (line.padding + margin);
			}
			bindedTo = line;
		}
		return bindedTo;
	}

	inline function get_isBinded() {
		return bindedTo != null;
	}
}
