package s2d.core.math.vectors;

import kha.FastFloat;

abstract Vec2(FVecN) from FVecN to FVecN {
	public static var size:Int = 2;

	public var x(get, set):FastFloat;
	public var y(get, set):FastFloat;
	public var length(get, set):FastFloat;
	public var normalized(get, never):FVecN;

	public inline function new(?x:FastFloat = 0.0, ?y:FastFloat = 0.0) {
		this = new FVecN(size, 0.0);
		this[0] = x;
		this[1] = y;
	}

	inline function get_x():FastFloat {
		return this[0];
	}

	inline function set_x(value:FastFloat):FastFloat {
		this[0] = value;
		return value;
	}

	inline function get_y():FastFloat {
		return this[1];
	}

	inline function set_y(value:FastFloat):FastFloat {
		this[1] = value;
		return value;
	}

	inline function get_length():FastFloat {
		return this.length;
	}

	inline function set_length(value:FastFloat):FastFloat {
		return this.length = value;
	}

	inline function get_normalized():Vec2 {
		return this.normalized;
	}

	@:arrayAccess
	inline function get(i:Int) {
		return this[i];
	}

	@:arrayAccess
	inline function set(i:Int, value:FastFloat) {
		this[i] = value;
	}

	@:op(a.b)
	function swizzleRead(name:String):Vec2 {
		return this.swizzleRead(name);
	}

	// Unary

	@:op(++A)
	inline function increment():Vec2 {
		return ++this;
	}

	@:op(A++)
	inline function postincrement():Vec2 {
		return this
		++;
	}

	@:op(--A)
	inline function decrement():Vec2 {
		return --this;
	}

	@:op(A--)
	inline function postdecrement():Vec2 {
		return this
		--;
	}

	@:op(-A)
	inline function negate():Vec2 {
		return -this;
	}

	// Binary

	public inline function dot(value:FVecN):FastFloat {
		return this.dot(value);
	}

	@:op(A + B) @:commutative
	inline function addFloat(value:FastFloat):Vec2 {
		return this + value;
	}

	@:op(A + B)
	inline function addFVecN(value:FVecN):Vec2 {
		return this + value;
	}

	@:op(A - B)
	inline function subFloat(value:FastFloat):Vec2 {
		return this - value;
	}

	@:op(A - B)
	inline function subFVecN(value:FVecN):Vec2 {
		return this - value;
	}

	@:op(A * B) @:commutative
	inline function mulFloat(value:FastFloat):Vec2 {
		return this * value;
	}

	@:op(A * B)
	inline function mulFVecN(value:FVecN):Vec2 {
		return this * value;
	}

	@:op(A / B)
	inline function divFloat(value:FastFloat):Vec2 {
		return this / value;
	}

	@:op(A / B)
	inline function divFVecN(value:FVecN):Vec2 {
		return this / value;
	}

	@:op(A % B)
	inline function modFloat(value:FastFloat):Vec2 {
		return this % value;
	}

	@:op(A % B)
	inline function modFVecN(value:FVecN):Vec2 {
		return this % value;
	}

	// Comparison

	@:op(A == B) @:commutative
	inline function equalsFloat(value:FastFloat):Bool {
		return this == value;
	}

	@:op(A == B)
	inline function equalsFVecN(value:FVecN):Bool {
		return this == value;
	}

	@:op(A != B) @:commutative
	inline function nequalsFloat(value:FastFloat):Bool {
		return this != value;
	}

	@:op(A != B)
	inline function nequalsFVecN(value:FVecN):Bool {
		return this != value;
	}

	@:op(A < B) @:commutative
	inline function ltFloat(value:FastFloat):Bool {
		return this < value;
	}

	@:op(A < B)
	inline function ltFVecN(value:FVecN):Bool {
		return this < value;
	}

	@:op(A <= B) @:commutative
	inline function ltequalsFloat(value:FastFloat):Bool {
		return this <= value;
	}

	@:op(A <= B)
	inline function ltequalsFVecN(value:FVecN):Bool {
		return this <= value;
	}

	@:op(A > B) @:commutative
	inline function gtFloat(value:FastFloat):Bool {
		return this > value;
	}

	@:op(A > B)
	inline function gtFVecN(value:FVecN):Bool {
		return this > value;
	}

	@:op(A >= B) @:commutative
	inline function gtequalsFloat(value:FastFloat):Bool {
		return this >= value;
	}

	@:op(A >= B)
	inline function gtequalsFVecN(value:FVecN):Bool {
		return this >= value;
	}
}
