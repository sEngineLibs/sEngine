package s2d.geometry;

import s2d.math.Vec2;

@:forward.new
abstract Size(Vec2) from Vec2 to Vec2 {
	public var width(get, set):Float;
	public var height(get, set):Float;

	function get_width():Float {
		return this.x;
	}

	function set_width(value:Float):Float {
		this.x = value;
		return value;
	}

	function get_height():Float {
		return this.y;
	}

	function set_height(value:Float):Float {
		this.y = value;
		return value;
	}

	@:to
	function toString():String {
		return '$width × $height';
	}
}
