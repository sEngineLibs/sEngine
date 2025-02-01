package s2d.geometry;

import kha.math.Vector4;

@:forward.new
@:forward(x, y)
abstract Rect(Vector4) from Vector4 to Vector4 {
	public var width(get, set):Float;
	public var height(get, set):Float;

	function get_width():Float {
		return this.z;
	}

	function set_width(value:Float):Float {
		this.z = value;
		return value;
	}

	function get_height():Float {
		return this.w;
	}

	function set_height(value:Float):Float {
		this.w = value;
		return value;
	}

	@:to
	function toString():String {
		return '$width × $height at (${this.x}, ${this.y})';
	}
}
