package s2d.geometry;

import s2d.math.Vec2I;

@:forward.new
@:forward(x, y)
abstract PositionI(Vec2I) from Vec2I to Vec2I {
	@:from
	public static inline function fromPosition(value:Position):PositionI {
		return new PositionI(Std.int(value.x), Std.int(value.y));
	}

	@:to
	public inline function toPosition():Position {
		return new Position(this.x, this.y);
	}

	@:to
	public inline function toString():String {
		return '(${this.x}, ${this.y})';
	}
}
