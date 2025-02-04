package s2d.geometry;

import s2d.math.Vec2;
import s2d.math.Vec4;

@:forward.new
@:forward(x, y)
abstract Rect(Vec4) from Vec4 to Vec4 {
	public var position(get, set):Vec2;
	public var width(get, set):Float;
	public var height(get, set):Float;
	public var size(get, set):Size;

	@:to
	public function toString():String {
		return '$size at (${this.x}, ${this.y})';
	}

	@:to
	public function toStringRounded():String {
		return '${Std.int(width)} × ${Std.int(height)} at (${Std.int(this.x)}, ${Std.int(this.y)})';
	}

	function get_position():Vec2 {
		return new Vec2(this.x, this.y);
	}

	function set_position(value:Vec2):Vec2 {
		this.x = value.x;
		this.y = value.y;
		return value;
	}

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

	function get_size():Size {
		return new Size(width, height);
	}

	function set_size(value:Size):Size {
		width = value.width;
		height = value.height;
		return value;
	}
}
