package s2d.core.math.vectors;

import kha.FastFloat;

abstract IVec3(IVecN) from IVecN to IVecN {
	public static var size:Int = 3;

	public var x(get, set):Int;
	public var y(get, set):Int;
	public var z(get, set):Int;
	public var length(get, set):FastFloat;
	public var normalized(get, never):IVecN;

	public inline function new(?x:Int = 0, ?y:Int = 0, ?z:Int = 0) {
		this = new IVecN(size, 0);
		this[0] = x;
		this[1] = y;
		this[2] = z;
	}

	inline function get_x():Int {
		return this[0];
	}

	inline function set_x(value:Int):Int {
		this[0] = value;
		return value;
	}

	inline function get_y():Int {
		return this[1];
	}

	inline function set_y(value:Int):Int {
		this[1] = value;
		return value;
	}

	inline function get_z():Int {
		return this[2];
	}

	inline function set_z(value:Int):Int {
		this[2] = value;
		return value;
	}

	inline function get_length():FastFloat {
		return this.length;
	}

	inline function set_length(value:FastFloat):FastFloat {
		return this.length = value;
	}

	inline function get_normalized():IVec2 {
		return this.normalized;
	}

	@:arrayAccess
	inline function get(i:Int) {
		return this[i];
	}

	@:arrayAccess
	inline function set(i:Int, value:Int) {
		this[i] = value;
	}

	@:op(a.b)
	function swizzleRead(name:String):IVecN {
		return this.swizzleRead(name);
	}

	// Unary

	@:op(++A)
	inline function increment():IVec2 {
		return ++this;
	}

	@:op(A++)
	inline function postincrement():IVec2 {
		return this
		++;
	}

	@:op(--A)
	inline function decrement():IVec2 {
		return --this;
	}

	@:op(A--)
	inline function postdecrement():IVec2 {
		return this
		--;
	}

	@:op(-A)
	inline function negate():IVec2 {
		return -this;
	}

	// Binary

	public inline function dot(value:IVecN):FastFloat {
		return this.dot(value);
	}

	@:op(A + B) @:commutative
	inline function addFloat(value:FastFloat):IVec2 {
		return this + value;
	}

	@:op(A + B)
	inline function addFVecN(value:IVecN):IVec2 {
		return this + value;
	}

	@:op(A - B)
	inline function subFloat(value:FastFloat):IVec2 {
		return this - value;
	}

	@:op(A - B)
	inline function subFVecN(value:IVecN):IVec2 {
		return this - value;
	}

	@:op(A * B) @:commutative
	inline function mulFloat(value:FastFloat):IVec2 {
		return this * value;
	}

	@:op(A * B)
	inline function mulFVecN(value:IVecN):IVec2 {
		return this * value;
	}

	@:op(A / B)
	inline function divFloat(value:FastFloat):IVec2 {
		return this / value;
	}

	@:op(A / B)
	inline function divFVecN(value:IVecN):IVec2 {
		return this / value;
	}

	@:op(A % B)
	inline function modFloat(value:FastFloat):IVec2 {
		return this % value;
	}

	@:op(A % B)
	inline function modFVecN(value:IVecN):IVec2 {
		return this % value;
	}

	// Comparison

	@:op(A == B) @:commutative
	inline function equalsFloat(value:FastFloat):Bool {
		return this == value;
	}

	@:op(A == B)
	inline function equalsFVecN(value:IVecN):Bool {
		return this == value;
	}

	@:op(A != B) @:commutative
	inline function nequalsFloat(value:FastFloat):Bool {
		return this != value;
	}

	@:op(A != B)
	inline function nequalsFVecN(value:IVecN):Bool {
		return this != value;
	}

	@:op(A < B) @:commutative
	inline function ltFloat(value:FastFloat):Bool {
		return this < value;
	}

	@:op(A < B)
	inline function ltFVecN(value:IVecN):Bool {
		return this < value;
	}

	@:op(A <= B) @:commutative
	inline function ltequalsFloat(value:FastFloat):Bool {
		return this <= value;
	}

	@:op(A <= B)
	inline function ltequalsFVecN(value:IVecN):Bool {
		return this <= value;
	}

	@:op(A > B) @:commutative
	inline function gtFloat(value:FastFloat):Bool {
		return this > value;
	}

	@:op(A > B)
	inline function gtFVecN(value:IVecN):Bool {
		return this > value;
	}

	@:op(A >= B) @:commutative
	inline function gtequalsFloat(value:FastFloat):Bool {
		return this >= value;
	}

	@:op(A >= B)
	inline function gtequalsFVecN(value:IVecN):Bool {
		return this >= value;
	}

	// Bitwise

	@:op(~A)
	inline function bitnot():IVec2 {
		return ~this;
	}

	@:op(A & B) @:commutative
	inline function bitandVal(value:Int):IVec2 {
		return this & value;
	}

	@:op(A & B)
	inline function bitandIVecN(value:IVecN):IVec2 {
		return this & value;
	}

	@:op(A | B) @:commutative
	inline function bitorVal(value:Int):IVec2 {
		return this | value;
	}

	@:op(A | B)
	inline function bitorIVecN(value:IVecN):IVec2 {
		return this | value;
	}

	@:op(A ^ B) @:commutative
	inline function bitxorVal(value:Int):IVec2 {
		return this ^ value;
	}

	@:op(A ^ B)
	inline function bitxorIVecN(value:IVecN):IVec2 {
		return this ^ value;
	}

	@:op(A << B)
	inline function lbitshiftVal(value:Int):IVec2 {
		return this << value;
	}

	@:op(A << B)
	inline function lbitshiftIVecN(value:IVecN):IVec2 {
		return this << value;
	}

	@:op(A >> B)
	inline function rbitshiftVal(value:Int):IVec2 {
		return this >> value;
	}

	@:op(A >> B)
	inline function rbitshiftIVecN(value:IVecN):IVec2 {
		return this >> value;
	}

	@:op(A >>> B)
	inline function urbitshiftVal(value:Int):IVec2 {
		return this >>> value;
	}

	@:op(A >>> B)
	inline function urbitshiftIVecN(value:IVecN):IVec2 {
		return this >>> value;
	}
}
