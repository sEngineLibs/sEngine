package s2d.anchors;

#if !macro
@:build(se.macro.SMacro.build())
@:autoBuild(se.macro.SMacro.build())
#end
abstract class AnchorLine<A:AnchorLine<A>> {
	var lines:Array<A> = [];
	var _position:Float = 0.0;
	var updating:Bool = false;

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

	function adjust(d:Float) {
		_position += d;
		updating = true;
		for (l in lines)
			l.position += d;
		updating = false;
	}

	abstract function syncOffset(d:Float):Void;

	function get_isBinded() {
		return bindedTo != null;
	}

	function set_bindedTo(value:A):A {
		if (value != bindedTo) {
			if (isBinded) {
				bindedTo.lines.remove(cast this);
				syncOffset(-(bindedTo.padding + margin));
			}
			if (value != null) {
				value.lines.push(cast this);
				position = value.position;
				syncOffset(value.padding + margin);
			}
			bindedTo = value;
		}
		return bindedTo;
	}

	function get_position():Float {
		return _position;
	}

	function set_position(value:Float):Float {
		if (!isBinded || bindedTo.updating)
			adjust(value - _position);
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
		for (line in lines)
			line.syncOffset(d);
		return margin;
	}
}

abstract class AnchorLineHorizontal extends AnchorLine<AnchorLineHorizontal> {}

class AnchorLineLeft extends AnchorLineHorizontal {
	function syncOffset(d:Float) {
		position += d;
	}
}

class AnchorLineHCenter extends AnchorLineHorizontal {
	function syncOffset(d:Float) {
		position += d;
	}
}

class AnchorLineRight extends AnchorLineHorizontal {
	function syncOffset(d:Float) {
		position -= d;
	}
}

abstract class AnchorLineVertical extends AnchorLine<AnchorLineVertical> {}

class AnchorLineTop extends AnchorLineVertical {
	function syncOffset(d:Float) {
		position += d;
	}
}

class AnchorLineVCenter extends AnchorLineVertical {
	function syncOffset(d:Float) {
		position += d;
	}
}

class AnchorLineBottom extends AnchorLineVertical {
	function syncOffset(d:Float) {
		position -= d;
	}
}
