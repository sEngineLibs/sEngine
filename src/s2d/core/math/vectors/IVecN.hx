package s2d.core.math.vectors;

import kha.FastFloat;

abstract IVecN(VecN<Int>) from VecN<Int> to VecN<Int> {
	public var size(get, never):Int;
	public var length(get, set):FastFloat;
	public var normalized(get, never):IVecN;

	public inline function new(size:Int, ?defaultValue:Int) {
		this = new VecN(size, defaultValue);
	}

	public inline function copy():IVecN {
		return this.copy();
	}

	@:arrayAccess
	public inline function get(i:Int) {
		return this[i];
	}

	@:arrayAccess
	public inline function set(i:Int, value:Int) {
		this[i] = value;
	}

	inline function get_size():Int {
		return this.size;
	}

	inline function get_length():FastFloat {
		var d = 0;
		for (x in this)
			d += x * x;
		return Math.sqrt(d);
	}

	inline function set_length(value:FastFloat):FastFloat {
		var l = length;
		if (l == 0)
			return 0;
		var m = Std.int(value / l);
		for (x in this)
			x *= m;
		return value;
	}

	inline function get_normalized():IVecN {
		final vec = copy();
		vec.length = 1;
		return vec;
	}

	@:op(a.b)
	public function swizzleRead(name:String):Dynamic {
		var vec = new IVecN(name.length);
		for (i in 0...name.length) {
			var ind = "xyzw".indexOf(name.charAt(i));
			if (ind == -1)
				ind = "rgba".indexOf(name.charAt(i));
			vec[i] = this[ind];
		}
		return vec;
	}

	public inline function dot(value:IVecN):Int {
		var s = 0;
		for (i in 0...(size < value.size ? size : value.size))
			s += this[i] * value[i];
		return s;
	}

	// Unary

	inline function uop(op:(Int) -> Int):IVecN {
		for (i in 0...size)
			this[i] = op(this[i]);
		return this;
	}

	@:op(++A)
	inline function increment():IVecN {
		return uop((f) -> f++);
	}

	@:op(A++)
	inline function postincrement():IVecN {
		return uop((f) -> ++f);
	}

	@:op(--A)
	inline function decrement():IVecN {
		return uop((f) -> --f);
	}

	@:op(A--)
	inline function postdecrement():IVecN {
		return uop((f) -> f--);
	}

	@:op(-A)
	inline function negate():IVecN {
		return uop((f) -> -f);
	}

	// Binary

	inline function bop1(op:(Int, Int) -> Int, value:Int):IVecN {
		var vec = copy();
		for (i in 0...size)
			vec[i] = op(this[i], value);
		return vec;
	}

	inline function bopn(op:(Int, Int) -> Int, value:IVecN):IVecN {
		var vec = copy();
		for (i in 0...size)
			vec[i] = op(this[i], value[i]);
		return vec;
	}

	@:op(A + B) @:commutative
	inline function addFloat(value:FastFloat):IVecN {
		return bop1((f1, f2) -> f1 + f2, Std.int(value));
	}

	@:op(A + B) @:commutative
	inline function addIVecN(value:IVecN):IVecN {
		return bopn((f1, f2) -> f1 + f2, value);
	}

	@:op(A - B)
	inline function subFloat(value:FastFloat):IVecN {
		return bop1((f1, f2) -> Std.int(f1 - f2), Std.int(value));
	}

	@:op(A - B)
	inline function subIVecN(value:IVecN):IVecN {
		return bopn((f1, f2) -> f1 - f2, value);
	}

	@:op(A * B) @:commutative
	inline function mulFloat(value:FastFloat):IVecN {
		return bop1((f1, f2) -> Std.int(f1 * f2), Std.int(value));
	}

	@:op(A * B) @:commutative
	inline function mulIVecN(value:IVecN):IVecN {
		return bopn((f1, f2) -> f1 * f2, value);
	}

	@:op(A / B)
	inline function divFloat(value:FastFloat):IVecN {
		return bop1((f1, f2) -> Std.int(f1 / f2), Std.int(value));
	}

	@:op(A / B)
	inline function divIVecN(value:IVecN):IVecN {
		return bopn((f1, f2) -> Std.int(f1 / f2), value);
	}

	@:op(A % B)
	inline function modFloat(value:FastFloat):IVecN {
		return bop1((f1, f2) -> Std.int(f1 % f2), Std.int(value));
	}

	@:op(A % B)
	inline function modIVecN(value:IVecN):IVecN {
		return bopn((f1, f2) -> f1 % f2, value);
	}

	// Comparison

	inline function cop(op:(FastFloat, FastFloat) -> Bool, value:FastFloat):Bool {
		return op(length, value);
	}

	@:op(A == B) @:commutative
	inline function equalsFloat(value:FastFloat):Bool {
		return cop((f1, f2) -> f1 == f2, value);
	}

	@:op(A == B) @:commutative
	inline function equalsIVecN(value:IVecN):Bool {
		return cop((f1, f2) -> f1 == f2, value.length);
	}

	@:op(A != B) @:commutative
	inline function nequalsFloat(value:FastFloat):Bool {
		return cop((f1, f2) -> f1 != f2, value);
	}

	@:op(A != B) @:commutative
	inline function nequalsIVecN(value:IVecN):Bool {
		return cop((f1, f2) -> f1 != f2, value.length);
	}

	@:op(A < B) @:commutative
	inline function ltFloat(value:FastFloat):Bool {
		return cop((f1, f2) -> f1 < f2, value);
	}

	@:op(A < B) @:commutative
	inline function ltIVecN(value:IVecN):Bool {
		return cop((f1, f2) -> f1 < f2, value.length);
	}

	@:op(A <= B) @:commutative
	inline function ltequalsFloat(value:FastFloat):Bool {
		return cop((f1, f2) -> f1 <= f2, value);
	}

	@:op(A <= B) @:commutative
	inline function ltequalsIVecN(value:IVecN):Bool {
		return cop((f1, f2) -> f1 <= f2, value.length);
	}

	@:op(A > B) @:commutative
	inline function gtFloat(value:FastFloat):Bool {
		return cop((f1, f2) -> f1 > f2, value);
	}

	@:op(A > B) @:commutative
	inline function gtIVecN(value:IVecN):Bool {
		return cop((f1, f2) -> f1 > f2, value.length);
	}

	@:op(A >= B) @:commutative
	inline function gtequalsFloat(value:FastFloat):Bool {
		return cop((f1, f2) -> f1 >= f2, value);
	}

	@:op(A >= B) @:commutative
	inline function gtequalsIVecN(value:IVecN):Bool {
		return cop((f1, f2) -> f1 >= f2, value.length);
	}

	// Bitwise

	@:op(~A)
	inline function bitnot():IVecN {
		return uop((f) -> ~f);
	}

	@:op(A & B)
	inline function bitandVal(value:Int):IVecN {
		return bop1((f1, f2) -> f1 & f2, value);
	}

	@:op(A & B)
	inline function bitandIVecN(value:IVecN):IVecN {
		return bopn((f1, f2) -> f1 & f2, value);
	}

	@:op(A | B)
	inline function bitorVal(value:Int):IVecN {
		return bop1((f1, f2) -> f1 | f2, value);
	}

	@:op(A | B)
	inline function bitorIVecN(value:IVecN):IVecN {
		return bopn((f1, f2) -> f1 | f2, value);
	}

	@:op(A ^ B)
	inline function bitxorVal(value:Int):IVecN {
		return bop1((f1, f2) -> f1 ^ f2, value);
	}

	@:op(A ^ B)
	inline function bitxorIVecN(value:IVecN):IVecN {
		return bopn((f1, f2) -> f1 ^ f2, value);
	}

	@:op(A << B)
	inline function lbitshiftVal(value:Int):IVecN {
		return bop1((f1, f2) -> f1 << f2, value);
	}

	@:op(A << B)
	inline function lbitshiftIVecN(value:IVecN):IVecN {
		return bopn((f1, f2) -> f1 << f2, value);
	}

	@:op(A >> B)
	inline function rbitshiftVal(value:Int):IVecN {
		return bop1((f1, f2) -> f1 >> f2, value);
	}

	@:op(A >> B)
	inline function rbitshiftIVecN(value:IVecN):IVecN {
		return bopn((f1, f2) -> f1 >> f2, value);
	}

	@:op(A >>> B)
	inline function urbitshiftVal(value:Int):IVecN {
		return bop1((f1, f2) -> f1 >>> f2, value);
	}

	@:op(A >>> B)
	inline function urbitshiftIVecN(value:IVecN):IVecN {
		return bopn((f1, f2) -> f1 >>> f2, value);
	}
}
