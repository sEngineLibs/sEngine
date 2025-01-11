package s2d.core.math.vectors;

import kha.FastFloat;

abstract FVecN(VecN<FastFloat>) from VecN<FastFloat> to VecN<FastFloat> {
	public var size(get, never):Int;
	public var length(get, set):FastFloat;
	public var normalized(get, never):FVecN;

	public inline function new(size:Int, ?defaultValue:FastFloat) {
		this = new VecN(size, defaultValue);
	}

	public inline function copy():FVecN {
		return this.copy();
	}

	@:arrayAccess
	public inline function get(i:Int) {
		return this[i];
	}

	@:arrayAccess
	public inline function set(i:Int, value:FastFloat) {
		this[i] = value;
	}

	inline function get_size():Int {
		return this.size;
	}

	inline function get_length():FastFloat {
		var d = 0.0;
		for (x in this)
			d += x * x;
		return Math.sqrt(d);
	}

	inline function set_length(value:FastFloat):FastFloat {
		var l = length;
		if (l == 0.0)
			return 0.0;
		var m = value / l;
		for (x in this)
			x *= m;
		return value;
	}

	inline function get_normalized():FVecN {
		final vec = copy();
		vec.length = 1.0;
		return vec;
	}

	@:to
	inline function toFloat():FastFloat {
		return this[0];
	}

	@:op(a.b)
	public function swizzleRead(name:String):Dynamic {
		var vec = new FVecN(name.length);
		for (i in 0...name.length) {
			var ind = "xyzw".indexOf(name.charAt(i));
			if (ind == -1)
				ind = "rgba".indexOf(name.charAt(i));
			vec[i] = this[ind];
		}
		return vec;
	}

	public inline function dot(value:FVecN):FastFloat {
		var s = 0.0;
		for (i in 0...(size < value.size ? size : value.size))
			s += this[i] * value[i];
		return s;
	}

	// Unary

	inline function uop(op:(FastFloat) -> FastFloat):FVecN {
		for (i in 0...size)
			this[i] = op(this[i]);
		return this;
	}

	@:op(++A)
	inline function increment():FVecN {
		return uop((f) -> f++);
	}

	@:op(A++)
	inline function postincrement():FVecN {
		return uop((f) -> ++f);
	}

	@:op(--A)
	inline function decrement():FVecN {
		return uop((f) -> --f);
	}

	@:op(A--)
	inline function postdecrement():FVecN {
		return uop((f) -> f--);
	}

	@:op(-A)
	inline function negate():FVecN {
		return uop((f) -> -f);
	}

	// Binary

	inline function bop1(op:(FastFloat, FastFloat) -> FastFloat, value:FastFloat):FVecN {
		var vec = copy();
		for (i in 0...size)
			this[i] = op(this[i], value);
		return vec;
	}

	inline function bopn(op:(FastFloat, FastFloat) -> FastFloat, value:FVecN):FVecN {
		var vec = copy();
		for (i in 0...size)
			this[i] = op(this[i], value[i]);
		return vec;
	}

	@:op(A + B) @:commutative
	inline function addFloat(value:FastFloat):FVecN {
		return bop1((f1, f2) -> f1 + f2, value);
	}

	@:op(A + B) @:commutative
	inline function addFVecN(value:FVecN):FVecN {
		return bopn((f1, f2) -> f1 + f2, value);
	}

	@:op(A - B)
	inline function subFloat(value:FastFloat):FVecN {
		return bop1((f1, f2) -> f1 - f2, value);
	}

	@:op(A - B)
	inline function subFVecN(value:FVecN):FVecN {
		return bopn((f1, f2) -> f1 - f2, value);
	}

	@:op(A * B) @:commutative
	inline function mulFloat(value:FastFloat):FVecN {
		return bop1((f1, f2) -> f1 * f2, value);
	}

	@:op(A * B) @:commutative
	inline function mulFVecN(value:FVecN):FVecN {
		return bopn((f1, f2) -> f1 * f2, value);
	}

	@:op(A / B)
	inline function divFloat(value:FastFloat):FVecN {
		return bop1((f1, f2) -> f1 / f2, value);
	}

	@:op(A / B)
	inline function divFVecN(value:FVecN):FVecN {
		return bopn((f1, f2) -> f1 / f2, value);
	}

	@:op(A % B)
	inline function modFloat(value:FastFloat):FVecN {
		return bop1((f1, f2) -> f1 % f2, value);
	}

	@:op(A % B)
	inline function modFVecN(value:FVecN):FVecN {
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
	inline function equalsFVecN(value:FVecN):Bool {
		return cop((f1, f2) -> f1 == f2, value.length);
	}

	@:op(A != B) @:commutative
	inline function nequalsFloat(value:FastFloat):Bool {
		return cop((f1, f2) -> f1 != f2, value);
	}

	@:op(A != B) @:commutative
	inline function nequalsFVecN(value:FVecN):Bool {
		return cop((f1, f2) -> f1 != f2, value.length);
	}

	@:op(A < B) @:commutative
	inline function ltFloat(value:FastFloat):Bool {
		return cop((f1, f2) -> f1 < f2, value);
	}

	@:op(A < B) @:commutative
	inline function ltFVecN(value:FVecN):Bool {
		return cop((f1, f2) -> f1 < f2, value.length);
	}

	@:op(A <= B) @:commutative
	inline function ltequalsFloat(value:FastFloat):Bool {
		return cop((f1, f2) -> f1 <= f2, value);
	}

	@:op(A <= B) @:commutative
	inline function ltequalsFVecN(value:FVecN):Bool {
		return cop((f1, f2) -> f1 <= f2, value.length);
	}

	@:op(A > B) @:commutative
	inline function gtFloat(value:FastFloat):Bool {
		return cop((f1, f2) -> f1 > f2, value);
	}

	@:op(A > B) @:commutative
	inline function gtFVecN(value:FVecN):Bool {
		return cop((f1, f2) -> f1 > f2, value.length);
	}

	@:op(A >= B) @:commutative
	inline function gtequalsFloat(value:FastFloat):Bool {
		return cop((f1, f2) -> f1 >= f2, value);
	}

	@:op(A >= B) @:commutative
	inline function gtequalsFVecN(value:FVecN):Bool {
		return cop((f1, f2) -> f1 >= f2, value.length);
	}
}
