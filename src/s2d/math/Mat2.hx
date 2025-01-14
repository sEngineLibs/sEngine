package s2d.math;

import kha.FastFloat;
import kha.math.FastMatrix2;

abstract Mat2(FastMatrix2) from FastMatrix2 to FastMatrix2 {
	#if !macro
	extern public static inline function empty():Mat2 {
		return FastMatrix2.empty();
	}

	extern public static inline function identity():Mat2 {
		return FastMatrix2.identity();
	}

	public inline function new(a00:FastFloat, a10:FastFloat, a01:FastFloat, a11:FastFloat) {
		this = new FastMatrix2(a00, a10, a01, a11);
	}

	public inline function set(a00:FastFloat, a10:FastFloat, a01:FastFloat, a11:FastFloat) {
		this._00 = a00;
		this._10 = a10;
		this._01 = a01;
		this._11 = a11;
	}

	public inline function copyFrom(m:Mat2):Mat2 {
		this.setFrom(m);
		return this;
	}

	public inline function clone():Mat2 {
		return Mat2.empty().copyFrom(this);
	}

	public inline function matrixCompMult(n:Mat2):Mat2 {
		var m = this;
		var n:FastMatrix2 = n;
		return new Mat2(m._00 * n._00, m._10 * n._10, m._01 * n._01, m._11 * n._11);
	}

	// extended methods

	public inline function transpose():Mat2 {
		return this.transpose();
	}

	public inline function determinant():FastFloat {
		var m = this;
		return m._00 * m._11 - m._01 * m._10;
	}

	public inline function inverse():Mat2 {
		var m = this;
		var f = 1.0 / determinant();
		return new Mat2(m._11 * f, -m._10 * f, -m._01 * f, m._00 * f);
	}

	public inline function adjoint():Mat2 {
		var m = this;
		return new Mat2(m._11, -m._10, -m._01, m._00);
	}

	public inline function toString() {
		return 'mat2(' + '${this._00}, ${this._10}, ' + '${this._01}, ${this._11}' + ')';
	}

	@:op([])
	inline function arrayRead(i:Int):Vec2
		return switch i {
			case 0: {
					x: this._00,
					y: this._10
				}
			case 1: {
					x: this._01,
					y: this._11
				}
			default: null;
		}

	@:op([])
	inline function arrayWrite(i:Int, v:Vec2)
		return switch i {
			case 0: {
					this._00 = v.x;
					this._10 = v.y;
				}
			case 1: {
					this._01 = v.x;
					this._11 = v.y;
				}
			default: null;
		}

	@:op(-a)
	static inline function neg(m:Mat2) {
		var m:FastMatrix2 = m;
		return new Mat2(-m._00, -m._10, -m._01, -m._11);
	}

	@:op(++a)
	static inline function prefixIncrement(m:Mat2):Mat2 {
		var m:FastMatrix2 = m;
		++m._00;
		++m._10;
		++m._01;
		++m._11;
		return Mat2.empty().copyFrom(m);
	}

	@:op(--a)
	static inline function prefixDecrement(m:Mat2) {
		var m:FastMatrix2 = m;
		--m._00;
		--m._10;
		--m._01;
		--m._11;
		return Mat2.empty().copyFrom(m);
	}

	@:op(a++)
	static inline function postfixIncrement(m:Mat2) {
		var ret = m.clone();
		var m:FastMatrix2 = m;
		++m._00;
		++m._10;
		++m._01;
		++m._11;
		return ret;
	}

	@:op(a--)
	static inline function postfixDecrement(m:Mat2) {
		var ret = m.clone();
		var m:FastMatrix2 = m;
		--m._00;
		--m._10;
		--m._01;
		--m._11;
		return ret;
	}

	// assignment overload should come before other binary ops to ensure they have priority

	@:op(a *= b)
	static inline function mulEq(a:Mat2, b:Mat2):Mat2
		return a.copyFrom(a * b);

	@:op(a *= b)
	static inline function mulEqScalar(a:Mat2, f:FastFloat):Mat2
		return a.copyFrom(a * f);

	@:op(a /= b)
	static inline function divEq(a:Mat2, b:Mat2):Mat2
		return a.copyFrom(a / b);

	@:op(a /= b)
	static inline function divEqScalar(a:Mat2, f:FastFloat):Mat2
		return a.copyFrom(a / f);

	@:op(a += b)
	static inline function addEq(a:Mat2, b:Mat2):Mat2
		return a.copyFrom(a + b);

	@:op(a += b)
	static inline function addEqScalar(a:Mat2, f:FastFloat):Mat2
		return a.copyFrom(a + f);

	@:op(a -= b)
	static inline function subEq(a:Mat2, b:Mat2):Mat2
		return a.copyFrom(a - b);

	@:op(a -= b)
	static inline function subEqScalar(a:Mat2, f:FastFloat):Mat2
		return a.copyFrom(a - f);

	@:op(a + b)
	static inline function add(m:Mat2, n:Mat2):Mat2 {
		var m:FastMatrix2 = m;
		var n:FastMatrix2 = n;
		return new Mat2(m._00 + n._00, m._10 + n._10, m._01 + n._01, m._11 + n._11);
	}

	@:op(a + b) @:commutative
	static inline function addScalar(m:Mat2, f:FastFloat):Mat2 {
		var m:FastMatrix2 = m;
		return new Mat2(m._00 + f, m._10 + f, m._01 + f, m._11 + f);
	}

	@:op(a - b)
	static inline function sub(m:Mat2, n:Mat2):Mat2 {
		var m:FastMatrix2 = m;
		var n:FastMatrix2 = n;
		return new Mat2(m._00 - n._00, m._10 - n._10, m._01 - n._01, m._11 - n._11);
	}

	@:op(a - b)
	static inline function subScalar(m:Mat2, f:FastFloat):Mat2 {
		var m:FastMatrix2 = m;
		return new Mat2(m._00 - f, m._10 - f, m._01 - f, m._11 - f);
	}

	@:op(a - b)
	static inline function subScalarInv(f:FastFloat, m:Mat2):Mat2 {
		var m:FastMatrix2 = m;
		return new Mat2(f - m._00, f - m._10, f - m._01, f - m._11);
	}

	@:op(a * b)
	static inline function mul(m:Mat2, n:Mat2):Mat2 {
		return (m : FastMatrix2).multmat(n);
	}

	@:op(a * b)
	static inline function postMulVec2(m:Mat2, v:Vec2):Vec2 {
		var m:FastMatrix2 = m;
		return new Vec2(m._00 * v.x + m._01 * v.y, m._10 * v.x + m._11 * v.y);
	}

	@:op(a * b)
	static inline function preMulVec2(v:Vec2, m:Mat2):Vec2 {
		return new Vec2(v.dot(m[0]), v.dot(m[1]));
	}

	@:op(a * b) @:commutative
	static inline function mulScalar(m:Mat2, f:FastFloat):Mat2 {
		return (m : FastMatrix2).mult(f);
	}

	@:op(a / b)
	static inline function div(m:Mat2, n:Mat2):Mat2 {
		return m.matrixCompMult(1.0 / n);
	}

	@:op(a / b)
	static inline function divScalar(m:Mat2, f:FastFloat):Mat2 {
		return (m : FastMatrix2).mult(1.0 / f);
	}

	@:op(a / b)
	static inline function divScalarInv(f:FastFloat, m:Mat2):Mat2 {
		var m:FastMatrix2 = m;
		return new Mat2(f / m._00, f / m._10, f / m._01, f / m._11);
	}

	@:op(a == b)
	static inline function equal(m:Mat2, n:Mat2):Bool {
		return m[0] == n[0] && m[1] == n[1];
	}

	@:op(a != b)
	static inline function notEqual(m:Mat2, n:Mat2):Bool
		return !equal(m, n);
	#end // !macro

	/**
		Copies matrix elements in column-major order into a type that supports array-write access
	**/
	@:overload(function<T>(arrayLike:T, index:Int):T {})
	public macro function copyIntoArray(self:haxe.macro.Expr.ExprOf<Mat2>, array:haxe.macro.Expr.ExprOf<ArrayAccess<FastFloat>>,
			index:haxe.macro.Expr.ExprOf<Int>) {
		return macro {
			var self = $self;
			var array = $array;
			var i:Int = $index;
			self[0].copyIntoArray(array, i);
			self[1].copyIntoArray(array, i + 2);
			array;
		}
	}

	/**
		Copies matrix elements in column-major order from a type that supports array-read access
	**/
	@:overload(function<T>(arrayLike:T, index:Int):Mat2 {})
	public macro function copyFromArray(self:haxe.macro.Expr.ExprOf<Mat2>, array:haxe.macro.Expr.ExprOf<ArrayAccess<FastFloat>>,
			index:haxe.macro.Expr.ExprOf<Int>) {
		return macro {
			var self = $self;
			var array = $array;
			var i:Int = $index;
			self[0].copyFromArray(array, i);
			self[1].copyFromArray(array, i + 2);
			self;
		}
	}

	// static macros

	@:overload(function<T>(arrayLike:T, index:Int):T {})
	public static macro function fromArray(array:ExprOf<ArrayAccess<FastFloat>>, index:ExprOf<Int>):ExprOf<Mat2> {
		return macro {
			var array = $array;
			var i:Int = $index;
			new Mat2(array[0 + i], array[1 + i], array[2 + i], array[3 + i]);
		}
	}
}
