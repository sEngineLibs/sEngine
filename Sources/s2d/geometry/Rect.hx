package s2d.geometry;

import kha.FastFloat;
import se.math.Vec4;

@:forward(x, y)
@:forward.new
abstract Rect(Vec4) from Vec4 to Vec4 {
	public var width(get, set):FastFloat;
	public var height(get, set):FastFloat;
	public var position(get, set):Position;
	public var size(get, set):Size;

	@:from
	public static inline function fromBounds(value:Bounds):Rect {
		return new Rect(value.left, value.top, value.right - value.left, value.bottom - value.top);
	}

	@:to
	public inline function toBounds():Bounds {
		return Bounds.fromRect(this);
	}

	@:to
	public inline function toRectI():RectI {
		return RectI.fromRect(this);
	}

	@:to
	public inline function toString():String {
		return '$size at $position';
	}

	private inline function get_width():FastFloat {
		return this.z;
	}

	private inline function set_width(value:FastFloat):FastFloat {
		this.z = value;
		return value;
	}

	private inline function get_height():FastFloat {
		return this.w;
	}

	private inline function set_height(value:FastFloat):FastFloat {
		this.w = value;
		return value;
	}

	private inline function get_position():Position {
		return new Position(this.x, this.y);
	}

	private inline function set_position(value:Position):Position {
		this.x = value.x;
		this.y = value.y;
		return value;
	}

	private inline function get_size():Size {
		return new Size(width, height);
	}

	private inline function set_size(value:Size):Size {
		width = size.width;
		height = size.height;
		return value;
	}
}
