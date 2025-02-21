package s2d.geometry;

import kha.FastFloat;
import se.math.Vec4;

@:forward.new
abstract Bounds(Vec4) from Vec4 to Vec4 {
	public var left(get, set):FastFloat;
	public var top(get, set):FastFloat;
	public var right(get, set):FastFloat;
	public var bottom(get, set):FastFloat;

	public inline function new(left:FastFloat, top:FastFloat, right:FastFloat, bottom:FastFloat) {
		this = new Vec4(left, top, right, bottom);
	}

	@:from
	public static inline function fromRect(value:Rect):Bounds {
		return new Bounds(value.x, value.y, value.x + value.width, value.y + value.height);
	}

	@:to
	public inline function toBoundsI():BoundsI {
		return BoundsI.fromBounds(this);
	}

	@:to
	public inline function toRect():Rect {
		return Rect.fromBounds(this);
	}

	@:to
	public inline function toString():String {
		return '($left, $top, $right, $bottom)';
	}

	inline function get_left():FastFloat {
		return this.x;
	}

	inline function set_left(value:FastFloat):FastFloat {
		this.x = value;
		return value;
	}

	inline function get_top():FastFloat {
		return this.y;
	}

	inline function set_top(value:FastFloat):FastFloat {
		this.y = value;
		return value;
	}

	inline function get_right():FastFloat {
		return this.z;
	}

	inline function set_right(value:FastFloat):FastFloat {
		this.z = value;
		return value;
	}

	inline function get_bottom():FastFloat {
		return this.w;
	}

	inline function set_bottom(value:FastFloat):FastFloat {
		this.w = value;
		return value;
	}
}
