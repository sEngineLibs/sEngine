package s2d.math;

import kha.FastFloat;
import kha.math.FastVector4;

abstract Rect(FastVector4) from FastVector4 to FastVector4 {
	public static var Identity = new Rect(0.0, 0.0, 1.0, 1.0);

	public var x(get, set):FastFloat;
	public var y(get, set):FastFloat;
	public var w(get, set):FastFloat;
	public var h(get, set):FastFloat;

	public inline function new(x:FastFloat, y:FastFloat, w:FastFloat, h:FastFloat) {
		this = new FastVector4(x, y, w, h);
	}

	public inline function add(value:Rect):Rect {
		return new Rect(x + value.x, y + value.y, w + value.w, h + value.h);
	}

	public inline function mult(value:Rect):Rect {
		return new Rect(x * value.x, y * value.y, w * value.w, h * value.h);
	}

	public inline function translate(x:FastFloat, y:FastFloat):Rect {
		return add(new Rect(x, y, x, y));
	}

	public inline function scale(x:FastFloat, y:FastFloat):Rect {
		return mult(new Rect(x, y, x, y));
	}

	public inline function crop(value:Rect):Rect {
		final cx = (w - x) * value.x;
		final cy = (h - y) * value.y;

		return new Rect(x + cx, y + cy, w - cx, h - cy);
	}

	inline function get_x():FastFloat {
		return this.x;
	}

	inline function set_x(value:FastFloat):FastFloat {
		this.x = value;
		return value;
	}

	inline function get_y():FastFloat {
		return this.y;
	}

	inline function set_y(value:FastFloat):FastFloat {
		this.y = value;
		return value;
	}

	inline function get_w():FastFloat {
		return this.z;
	}

	inline function set_w(value:FastFloat):FastFloat {
		this.z = value;
		return value;
	}

	inline function get_h():FastFloat {
		return this.w;
	}

	inline function set_h(value:FastFloat):FastFloat {
		this.w = value;
		return value;
	}
}
