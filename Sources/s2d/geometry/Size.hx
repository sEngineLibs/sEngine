package s2d.geometry;

import kha.FastFloat;
import se.math.Vec2;

abstract Size(Vec2) from Vec2 to Vec2 {
	public var width(get, set):FastFloat;
	public var height(get, set):FastFloat;

	public inline function new(width:FastFloat, height:FastFloat):Size {
		this = new Vec2(width, height);
	}

	@:from
	public static inline function fromString(value:String):Size {
		var size = value.split("x");
		return new Size(Std.parseFloat(size[0]), Std.parseFloat(size[1]));
	}

	@:to
	public inline function toSizeI():SizeI {
		return SizeI.fromSize(this);
	}

	@:to
	public inline function toString():String {
		return '${width}x${height}';
	}

	private inline function get_width():FastFloat {
		return this.x;
	}

	private inline function set_width(value:FastFloat):FastFloat {
		this.x = value;
		return value;
	}

	private inline function get_height():FastFloat {
		return this.y;
	}

	private inline function set_height(value:FastFloat):FastFloat {
		this.y = value;
		return value;
	}
}
