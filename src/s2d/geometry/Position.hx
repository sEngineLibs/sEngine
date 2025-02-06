package s2d.geometry;

import s2d.math.Vec2;

@:forward.new
@:forward(x, y)
abstract Position(Vec2) from Vec2 to Vec2 {
	@:to
	public inline function toPositionI():PositionI {
		return PositionI.fromPosition(this);
	}

	@:to
	public inline function toString():String {
		return '(${this.x}, ${this.y})';
	}
}
