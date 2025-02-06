package s2d.geometry;

import s2d.math.Vec2I;

abstract SizeI(Vec2I) from Vec2I to Vec2I {
	public var width(get, set):Int;
	public var height(get, set):Int;

	public inline function new(width:Int, height:Int):SizeI {
		this = new Vec2I(width, height);
	}

	@:from
	public static inline function fromSize(value:Size):SizeI {
		return new SizeI(Std.int(value.width), Std.int(value.height));
	}

	@:from
	public static inline function fromString(value:String):SizeI {
		var size = value.split("x");
		return new SizeI(Std.parseInt(size[0]), Std.parseInt(size[1]));
	}

	@:to
	public inline function toSize():Size {
		return new Size(width, height);
	}

	@:to
	public inline function toString():String {
		return '${width}x${height}';
	}

	inline function get_width():Int {
		return this.x;
	}

	inline function set_width(value:Int):Int {
		this.x = value;
		return value;
	}

	inline function get_height():Int {
		return this.y;
	}

	inline function set_height(value:Int):Int {
		this.y = value;
		return value;
	}
}
