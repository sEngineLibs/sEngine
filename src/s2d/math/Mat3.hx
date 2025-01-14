package s2d.math;

import kha.FastFloat;
import kha.math.FastMatrix3;
// s2d
import s2d.math.SMath;

abstract Mat3(FastMatrix3) from FastMatrix3 to FastMatrix3 {
	#if !macro
	extern public static inline function empty():Mat3 {
		return FastMatrix3.empty();
	}

	extern public static inline function identity():Mat3 {
		return FastMatrix3.identity();
	}

	extern public static inline function translation(x:FastFloat, y:FastFloat):Mat3 {
		return FastMatrix3.translation(x, y);
	}

	extern public static inline function scale(x:FastFloat, y:FastFloat):Mat3 {
		return FastMatrix3.scale(x, y);
	}

	extern public static inline function rotation(alpha:FastFloat):Mat3 {
		return FastMatrix3.rotation(alpha);
	}

	extern public static inline function orthogonalProjection(left:FastFloat, right:FastFloat, bottom:FastFloat, top:FastFloat):Mat3 {
		var tx = -(right + left) / (right - left);
		var ty = -(top + bottom) / (top - bottom);

		return mat3(2 / (right - left), 0, tx, 0, 2.0 / (top - bottom), ty, 0, 0, 1);
	}

	extern public static inline function lookAt(eye:Vec2, at:Vec2, up:Vec2):Mat3 {
		var zaxis = normalize(at - eye);
		var xaxis = vec2(-zaxis.y, zaxis.x);
		return mat3(xaxis.x, xaxis.y, dot(-xaxis, eye), -zaxis.x, -zaxis.y, dot(zaxis, eye), 0, 0, 1);
	}

	public inline function new(a00:FastFloat, a10:FastFloat, a20:FastFloat, a01:FastFloat, a11:FastFloat, a21:FastFloat, a02:FastFloat, a12:FastFloat,
			a22:FastFloat) {
		this = new FastMatrix3(a00, a10, a20, a01, a11, a21, a02, a12, a22);
	}

	public inline function set(a00:FastFloat, a10:FastFloat, a20:FastFloat, a01:FastFloat, a11:FastFloat, a21:FastFloat, a02:FastFloat, a12:FastFloat,
			a22:FastFloat) {
		this._00 = a00;
		this._10 = a10;
		this._20 = a20;
		this._01 = a01;
		this._11 = a11;
		this._21 = a21;
		this._02 = a02;
		this._12 = a12;
		this._22 = a22;
	}

	public inline function copyFrom(m:Mat3) {
		var m:FastMatrix3 = m;
		this._00 = m._00;
		this._10 = m._10;
		this._20 = m._20;
		this._01 = m._01;
		this._11 = m._11;
		this._21 = m._21;
		this._02 = m._02;
		this._12 = m._12;
		this._22 = m._22;
		return this;
	}

	public inline function clone():Mat3 {
		return Mat3.empty().copyFrom(this);
	}

	public inline function matrixCompMult(n:Mat3):Mat3 {
		var n:FastMatrix3 = n;
		return new Mat3(this._00 * n._00, this._10 * n._10, this._20 * n._20, this._01 * n._01, this._11 * n._11, this._21 * n._21, this._02 * n._02,
			this._12 * n._12, this._22 * n._22);
	}

	// extended methods

	public inline function transpose():Mat3 {
		return this.transpose();
	}

	public inline function determinant():FastFloat {
		return this.determinant();
	}

	public inline function inverse():Mat3 {
		return this.inverse();
	}

	public inline function adjoint():Mat3 {
		var m = this;
		return new Mat3(m._11 * m._22
			- m._21 * m._12, m._20 * m._12
			- m._10 * m._22, m._10 * m._21
			- m._20 * m._11, m._21 * m._02
			- m._01 * m._22,
			m._00 * m._22
			- m._20 * m._02, m._20 * m._01
			- m._00 * m._21, m._01 * m._12
			- m._11 * m._02, m._10 * m._02
			- m._00 * m._12,
			m._00 * m._11
			- m._10 * m._01);
	}

	public inline function toString() {
		return 'mat3('
			+ '${this._00}, ${this._10}, ${this._20}, '
			+ '${this._01}, ${this._11}, ${this._21}, '
			+ '${this._02}, ${this._12}, ${this._22}'
			+ ')';
	}

	@:op([])
	inline function arrayRead(i:Int):Vec3
		return switch i {
			case 0: {
					x: this._00,
					y: this._10,
					z: this._20
				}
			case 1: {
					x: this._01,
					y: this._11,
					z: this._21
				}
			case 2: {
					x: this._02,
					y: this._12,
					z: this._22
				}
			default: null;
		}

	@:op([])
	inline function arrayWrite(i:Int, v:Vec3)
		return switch i {
			case 0: {
					this._00 = v.x;
					this._10 = v.y;
					this._20 = v.z;
				}
			case 1: {
					this._01 = v.x;
					this._11 = v.y;
					this._21 = v.z;
				}
			case 2: {
					this._02 = v.x;
					this._12 = v.y;
					this._22 = v.z;
				}
			default: null;
		}

	@:op(-a)
	static inline function neg(m:Mat3) {
		var m:FastMatrix3 = m;
		return new Mat3(-m._00, -m._10, -m._20, -m._01, -m._11, -m._21, -m._02, -m._12, -m._22);
	}

	@:op(++a)
	static inline function prefixIncrement(m:Mat3) {
		var m:FastMatrix3 = m;
		++m._00;
		++m._10;
		++m._20;
		++m._01;
		++m._11;
		++m._21;
		++m._02;
		++m._12;
		++m._22;
		return Mat3.empty().copyFrom(m);
	}

	@:op(--a)
	static inline function prefixDecrement(m:Mat3) {
		var m:FastMatrix3 = m;
		--m._00;
		--m._10;
		--m._20;
		--m._01;
		--m._11;
		--m._21;
		--m._02;
		--m._12;
		--m._22;
		return Mat3.empty().copyFrom(m);
	}

	@:op(a++)
	static inline function postfixIncrement(m:Mat3) {
		var ret = m.clone();
		var m:FastMatrix3 = m;
		++m._00;
		++m._10;
		++m._20;
		++m._01;
		++m._11;
		++m._21;
		++m._02;
		++m._12;
		++m._22;
		return ret;
	}

	@:op(a--)
	static inline function postfixDecrement(m:Mat3) {
		var ret = m.clone();
		var m:FastMatrix3 = m;
		--m._00;
		--m._10;
		--m._20;
		--m._01;
		--m._11;
		--m._21;
		--m._02;
		--m._12;
		--m._22;
		return ret;
	}

	// assignment overload should come before other binary ops to ensure they have priority

	@:op(a *= b)
	static inline function mulEq(a:Mat3, b:Mat3):Mat3
		return a.copyFrom(a * b);

	@:op(a *= b)
	static inline function mulEqScalar(a:Mat3, f:FastFloat):Mat3
		return a.copyFrom(a * f);

	@:op(a /= b)
	static inline function divEq(a:Mat3, b:Mat3):Mat3
		return a.copyFrom(a / b);

	@:op(a /= b)
	static inline function divEqScalar(a:Mat3, f:FastFloat):Mat3
		return a.copyFrom(a / f);

	@:op(a += b)
	static inline function addEq(a:Mat3, b:Mat3):Mat3
		return a.copyFrom(a + b);

	@:op(a += b)
	static inline function addEqScalar(a:Mat3, f:FastFloat):Mat3
		return a.copyFrom(a + f);

	@:op(a -= b)
	static inline function subEq(a:Mat3, b:Mat3):Mat3
		return a.copyFrom(a - b);

	@:op(a -= b)
	static inline function subEqScalar(a:Mat3, f:FastFloat):Mat3
		return a.copyFrom(a - f);

	@:op(a + b)
	static inline function add(m:Mat3, n:Mat3):Mat3 {
		return (m : FastMatrix3).add((n : FastMatrix3));
	}

	@:op(a + b) @:commutative
	static inline function addScalar(m:Mat3, f:FastFloat):Mat3 {
		var m:FastMatrix3 = m;
		return new Mat3(m._00 + f, m._10 + f, m._20 + f, m._01 + f, m._11 + f, m._21 + f, m._02 + f, m._12 + f, m._22 + f);
	}

	@:op(a - b)
	static inline function sub(m:Mat3, n:Mat3):Mat3 {
		var m:FastMatrix3 = m;
		var n:FastMatrix3 = n;
		return new Mat3(m._00
			- n._00, m._10
			- n._10, m._20
			- n._20, m._01
			- n._01, m._11
			- n._11, m._21
			- n._21, m._02
			- n._02, m._12
			- n._12, m._22
			- n._22);
	}

	@:op(a - b)
	static inline function subScalar(m:Mat3, f:FastFloat):Mat3 {
		var m:FastMatrix3 = m;
		return new Mat3(m._00 - f, m._10 - f, m._20 - f, m._01 - f, m._11 - f, m._21 - f, m._02 - f, m._12 - f, m._22 - f);
	}

	@:op(a - b)
	static inline function subScalarInv(f:FastFloat, m:Mat3):Mat3 {
		var m:FastMatrix3 = m;
		return new Mat3(f - m._00, f - m._10, f - m._20, f - m._01, f - m._11, f - m._21, f - m._02, f - m._12, f - m._22);
	}

	@:op(a * b)
	static inline function mul(m:Mat3, n:Mat3):Mat3 {
		return (m : FastMatrix3).multmat(n);
	}

	@:op(a * b)
	static inline function postMulVec3(m:Mat3, v:Vec3):Vec3 {
		var m:FastMatrix3 = m;
		return new Vec3(m._00 * v.x
			+ m._01 * v.y
			+ m._02 * v.z, m._10 * v.x
			+ m._11 * v.y
			+ m._12 * v.z, m._20 * v.x
			+ m._21 * v.y
			+ m._22 * v.z);
	}

	@:op(a * b)
	static inline function preMulVec3(v:Vec3, m:Mat3):Vec3 {
		return new Vec3(v.dot(m[0]), v.dot(m[1]), v.dot(m[2]));
	}

	@:op(a * b) @:commutative
	static inline function mulScalar(m:Mat3, f:FastFloat):Mat3 {
		return (m : FastMatrix3).mult(f);
	}

	@:op(a / b)
	static inline function div(m:Mat3, n:Mat3):Mat3
		return m.matrixCompMult(1.0 / n);

	@:op(a / b)
	static inline function divScalar(m:Mat3, f:FastFloat):Mat3 {
		return (m : FastMatrix3).mult(1.0 / f);
	}

	@:op(a / b)
	static inline function divScalarInv(f:FastFloat, m:Mat3):Mat3 {
		var m:FastMatrix3 = m;
		return new Mat3(f / m._00, f / m._10, f / m._20, f / m._01, f / m._11, f / m._21, f / m._02, f / m._12, f / m._22);
	}

	@:op(a == b)
	static inline function equal(m:Mat3, n:Mat3):Bool {
		return m[0] == n[0] && m[1] == n[1] && m[2] == n[2];
	}

	@:op(a != b)
	static inline function notEqual(m:Mat3, n:Mat3):Bool
		return !equal(m, n);
	#end // !macro

	/**
		Copies matrix elements in column-major order into a type that supports array-write access
	**/
	@:overload(function<T>(arrayLike:T, index:Int):T {})
	public macro function copyIntoArray(self:haxe.macro.Expr.ExprOf<Mat3>, array:haxe.macro.Expr.ExprOf<ArrayAccess<FastFloat>>,
			index:haxe.macro.Expr.ExprOf<Int>) {
		return macro {
			var self = $self;
			var array = $array;
			var i:Int = $index;
			self[0].copyIntoArray(array, i);
			self[1].copyIntoArray(array, i + 3);
			self[2].copyIntoArray(array, i + 6);
			array;
		}
	}

	/**
		Copies matrix elements in column-major order from a type that supports array-read access
	**/
	@:overload(function<T>(arrayLike:T, index:Int):Mat3 {})
	public macro function copyFromArray(self:haxe.macro.Expr.ExprOf<Mat3>, array:haxe.macro.Expr.ExprOf<ArrayAccess<FastFloat>>,
			index:haxe.macro.Expr.ExprOf<Int>) {
		return macro {
			var self = $self;
			var array = $array;
			var i:Int = $index;
			self[0].copyFromArray(array, i);
			self[1].copyFromArray(array, i + 3);
			self[2].copyFromArray(array, i + 6);
			self;
		}
	}

	// static macros

	@:overload(function<T>(arrayLike:T, index:Int):T {})
	public static macro function fromArray(array:ExprOf<ArrayAccess<FastFloat>>, index:ExprOf<Int>):ExprOf<Mat3> {
		return macro {
			var array = $array;
			var i:Int = $index;
			new Mat3(array[0 + i], array[1 + i], array[2 + i], array[3 + i], array[4 + i], array[5 + i], array[6 + i], array[7 + i], array[8 + i]);
		}
	}
}
