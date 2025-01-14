package s2d.math;

import kha.FastFloat;
import kha.math.FastMatrix4;

@:forward(_00, _10, _20, _30, _01, _11, _21, _31, _02, _12, _22, _32, _03, _13, _23, _33)
abstract Mat4(FastMatrix4) from FastMatrix4 to FastMatrix4 {
	#if !macro
	extern public static inline function identity():Mat4 {
		return FastMatrix4.identity();
	}

	extern public static inline function empty():Mat4 {
		return FastMatrix4.empty();
	}

	extern public static inline function orthogonalProjection(left:FastFloat, right:FastFloat, bottom:FastFloat, top:FastFloat, zn:FastFloat,
			zf:FastFloat):Mat4 {
		return FastMatrix4.orthogonalProjection(left, right, bottom, top, zn, zf);
	}

	extern public static inline function perspectiveProjection(fovY:FastFloat, aspect:FastFloat, zn:FastFloat, zf:FastFloat):Mat4 {
		return FastMatrix4.perspectiveProjection(fovY, aspect, zn, zf);
	}

	extern public static inline function lookAt(eye:Vec3, at:Vec3, up:Vec3):Mat4 {
		return FastMatrix4.lookAt(eye, at, up);
	}

	public inline function new(a00:FastFloat, a10:FastFloat, a20:FastFloat, a30:FastFloat, a01:FastFloat, a11:FastFloat, a21:FastFloat, a31:FastFloat,
			a02:FastFloat, a12:FastFloat, a22:FastFloat, a32:FastFloat, a03:FastFloat, a13:FastFloat, a23:FastFloat, a33:FastFloat) {
		this = new FastMatrix4(a00, a10, a20, a30, a01, a11, a21, a31, a02, a12, a22, a32, a03, a13, a23, a33);
	}

	public inline function set(a00:FastFloat, a10:FastFloat, a20:FastFloat, a30:FastFloat, a01:FastFloat, a11:FastFloat, a21:FastFloat, a31:FastFloat,
			a02:FastFloat, a12:FastFloat, a22:FastFloat, a32:FastFloat, a03:FastFloat, a13:FastFloat, a23:FastFloat, a33:FastFloat) {
		this._00 = a00;
		this._10 = a10;
		this._20 = a20;
		this._30 = a30;
		this._01 = a01;
		this._11 = a11;
		this._21 = a21;
		this._31 = a31;
		this._02 = a02;
		this._12 = a12;
		this._22 = a22;
		this._32 = a32;
		this._03 = a03;
		this._13 = a13;
		this._23 = a23;
		this._33 = a33;
	}

	public inline function copyFrom(m:Mat4) {
		this.setFrom(m);
		return this;
	}

	public inline function clone():Mat4 {
		return Mat4.empty().copyFrom(this);
	}

	public inline function matrixCompMult(n:Mat4):Mat4 {
		var m = this;
		var n:FastMatrix4 = n;
		return new Mat4(m._00 * n._00, m._10 * n._10, m._20 * n._20, m._30 * n._30, m._01 * n._01, m._11 * n._11, m._21 * n._21, m._31 * n._31, m._02 * n._02,
			m._12 * n._12, m._22 * n._22, m._32 * n._32, m._03 * n._03, m._13 * n._13, m._23 * n._23, m._33 * n._33);
	}

	// extended methods

	public inline function transpose():Mat4 {
		return this.transpose();
	}

	public inline function determinant():FastFloat {
		return this.determinant();
	}

	public inline function inverse():Mat4 {
		return this.inverse();
	}

	public inline function adjoint():Mat4 {
		var m = this;
		var b00 = m._00 * m._11 - m._10 * m._01;
		var b01 = m._00 * m._21 - m._20 * m._01;
		var b02 = m._00 * m._31 - m._30 * m._01;
		var b03 = m._10 * m._21 - m._20 * m._11;
		var b04 = m._10 * m._31 - m._30 * m._11;
		var b05 = m._20 * m._31 - m._30 * m._21;
		var b06 = m._02 * m._13 - m._12 * m._03;
		var b07 = m._02 * m._23 - m._22 * m._03;
		var b08 = m._02 * m._33 - m._32 * m._03;
		var b09 = m._12 * m._23 - m._22 * m._13;
		var b10 = m._12 * m._33 - m._32 * m._13;
		var b11 = m._22 * m._33 - m._32 * m._23;
		return new Mat4(m._11 * b11
			- m._21 * b10
			+ m._31 * b09, m._20 * b10
			- m._10 * b11
			- m._30 * b09, m._13 * b05
			- m._23 * b04
			+ m._33 * b03,
			m._22 * b04
			- m._12 * b05
			- m._32 * b03, m._21 * b08
			- m._01 * b11
			- m._31 * b07, m._00 * b11
			- m._20 * b08
			+ m._30 * b07,
			m._23 * b02
			- m._03 * b05
			- m._33 * b01, m._02 * b05
			- m._22 * b02
			+ m._32 * b01, m._01 * b10
			- m._11 * b08
			+ m._31 * b06,
			m._10 * b08
			- m._00 * b10
			- m._30 * b06, m._03 * b04
			- m._13 * b02
			+ m._33 * b00, m._12 * b02
			- m._02 * b04
			- m._32 * b00,
			m._11 * b07
			- m._01 * b09
			- m._21 * b06, m._00 * b09
			- m._10 * b07
			+ m._20 * b06, m._13 * b01
			- m._03 * b03
			- m._23 * b00,
			m._02 * b03
			- m._12 * b01
			+ m._22 * b00);
	}

	public inline function toString() {
		return 'mat4(' + '${this._00}, ${this._10}, ${this._20}, ${this._30}, ' + '${this._01}, ${this._11}, ${this._21}, ${this._31}, '
			+ '${this._02}, ${this._12}, ${this._22}, ${this._32}, ' + '${this._03}, ${this._13}, ${this._23}, ${this._33}' + ')';
	}

	@:op(-a)
	static inline function neg(m:Mat4) {
		var m:FastMatrix4 = m;
		return new Mat4(-m._00,
			-m._10,
			-m._20,
			-m._30,
			-m._01,
			-m._11,
			-m._21,
			-m._31,
			-m._02,
			-m._12,
			-m._22,
			-m._32,
			-m._03,
			-m._13,
			-m._23,
			-m._33);
	}

	@:op(++a)
	static inline function prefixIncrement(m:Mat4) {
		var m:FastMatrix4 = m;
		++m._00;
		++m._10;
		++m._20;
		++m._30;
		++m._01;
		++m._11;
		++m._21;
		++m._31;
		++m._02;
		++m._12;
		++m._22;
		++m._32;
		++m._03;
		++m._13;
		++m._23;
		++m._33;
		return Mat4.empty().copyFrom(m);
	}

	@:op(--a)
	static inline function prefixDecrement(m:Mat4) {
		var m:FastMatrix4 = m;
		--m._00;
		--m._10;
		--m._20;
		--m._30;
		--m._01;
		--m._11;
		--m._21;
		--m._31;
		--m._02;
		--m._12;
		--m._22;
		--m._32;
		--m._03;
		--m._13;
		--m._23;
		--m._33;
		return Mat4.empty().copyFrom(m);
	}

	@:op(a++)
	static inline function postfixIncrement(m:Mat4) {
		var ret = m.clone();
		var m:FastMatrix4 = m;
		++m._00;
		++m._10;
		++m._20;
		++m._30;
		++m._01;
		++m._11;
		++m._21;
		++m._31;
		++m._02;
		++m._12;
		++m._22;
		++m._32;
		++m._03;
		++m._13;
		++m._23;
		++m._33;
		return ret;
	}

	@:op(a--)
	static inline function postfixDecrement(m:Mat4) {
		var ret = m.clone();
		var m:FastMatrix4 = m;
		--m._00;
		--m._10;
		--m._20;
		--m._30;
		--m._01;
		--m._11;
		--m._21;
		--m._31;
		--m._02;
		--m._12;
		--m._22;
		--m._32;
		--m._03;
		--m._13;
		--m._23;
		--m._33;
		return ret;
	}

	// assignment overload should come before other binary ops to ensure they have priority

	@:op(a *= b)
	static inline function mulEq(a:Mat4, b:Mat4):Mat4
		return a.copyFrom(a * b);

	@:op(a *= b)
	static inline function mulEqScalar(a:Mat4, f:FastFloat):Mat4
		return a.copyFrom(a * f);

	@:op(a /= b)
	static inline function divEq(a:Mat4, b:Mat4):Mat4
		return a.copyFrom(a / b);

	@:op(a /= b)
	static inline function divEqScalar(a:Mat4, f:FastFloat):Mat4
		return a.copyFrom(a / f);

	@:op(a += b)
	static inline function addEq(a:Mat4, b:Mat4):Mat4
		return a.copyFrom(a + b);

	@:op(a += b)
	static inline function addEqScalar(a:Mat4, f:FastFloat):Mat4
		return a.copyFrom(a + f);

	@:op(a -= b)
	static inline function subEq(a:Mat4, b:Mat4):Mat4
		return a.copyFrom(a - b);

	@:op(a -= b)
	static inline function subEqScalar(a:Mat4, f:FastFloat):Mat4
		return a.copyFrom(a - f);

	@:op(a + b)
	static inline function add(m:Mat4, n:Mat4):Mat4 {
		return (m : FastMatrix4).add(n);
	}

	@:op(a + b) @:commutative
	static inline function addScalar(m:Mat4, f:FastFloat):Mat4 {
		var m:FastMatrix4 = m;
		return new Mat4(m._00
			+ f, m._10
			+ f, m._20
			+ f, m._30
			+ f, m._01
			+ f, m._11
			+ f, m._21
			+ f, m._31
			+ f, m._02
			+ f, m._12
			+ f, m._22
			+ f, m._32
			+ f,
			m._03
			+ f, m._13
			+ f, m._23
			+ f, m._33
			+ f);
	}

	@:op(a - b)
	static inline function sub(m:Mat4, n:Mat4):Mat4 {
		var m:FastMatrix4 = m;
		var n:FastMatrix4 = n;
		return new Mat4(m._00
			- n._00, m._10
			- n._10, m._20
			- n._20, m._30
			- n._30, m._01
			- n._01, m._11
			- n._11, m._21
			- n._21, m._31
			- n._31, m._02
			- n._02,
			m._12
			- n._12, m._22
			- n._22, m._32
			- n._32, m._03
			- n._03, m._13
			- n._13, m._23
			- n._23, m._33
			- n._33);
	}

	@:op(a - b)
	static inline function subScalar(m:Mat4, f:FastFloat):Mat4 {
		var m:FastMatrix4 = m;
		return new Mat4(m._00
			- f, m._10
			- f, m._20
			- f, m._30
			- f, m._01
			- f, m._11
			- f, m._21
			- f, m._31
			- f, m._02
			- f, m._12
			- f, m._22
			- f, m._32
			- f,
			m._03
			- f, m._13
			- f, m._23
			- f, m._33
			- f);
	}

	@:op(a - b)
	static inline function subScalarInv(f:FastFloat, m:Mat4):Mat4 {
		var m:FastMatrix4 = m;
		return new Mat4(f
			- m._00, f
			- m._10, f
			- m._20, f
			- m._30, f
			- m._01, f
			- m._11, f
			- m._21, f
			- m._31, f
			- m._02, f
			- m._12, f
			- m._22, f
			- m._32,
			f
			- m._03, f
			- m._13, f
			- m._23, f
			- m._33);
	}

	@:op(a * b)
	static inline function mul(m:Mat4, n:Mat4):Mat4 {
		return (m : FastMatrix4).multmat(n);
	}

	@:op(a * b)
	static inline function postMulVec4(m:Mat4, v:Vec4):Vec4 {
		return (m : FastMatrix4).multvec(v);
	}

	@:op(a * b)
	static inline function preMulVec4(v:Vec4, m:Mat4):Vec4 {
		return new Vec4(v.dot({
			x: m._00,
			y: m._10,
			z: m._20,
			w: m._30
		}), v.dot({
			x: m._01,
			y: m._11,
			z: m._21,
			w: m._31
		}), v.dot({
			x: m._02,
			y: m._12,
			z: m._22,
			w: m._32
		}), v.dot({
			x: m._03,
			y: m._13,
			z: m._23,
			w: m._33
		}));
	}

	@:op(a * b) @:commutative
	static inline function mulScalar(m:Mat4, f:FastFloat):Mat4 {
		return (m : FastMatrix4).mult(f);
	}

	@:op(a / b)
	static inline function div(m:Mat4, n:Mat4):Mat4
		return m.matrixCompMult(1.0 / n);

	@:op(a / b)
	static inline function divScalar(m:Mat4, f:FastFloat):Mat4 {
		return (m : FastMatrix4).mult(1.0 / f);
	}

	@:op(a / b)
	static inline function divScalarInv(f:FastFloat, m:Mat4):Mat4 {
		var m:FastMatrix4 = m;
		return new Mat4(f / m._00, f / m._10, f / m._20, f / m._30, f / m._01, f / m._11, f / m._21, f / m._31, f / m._02, f / m._12, f / m._22, f / m._32,
			f / m._03, f / m._13, f / m._23, f / m._33);
	}

	@:op(a == b)
	static inline function equal(m:Mat4, n:Mat4):Bool {
		return m._00 == n._00 && m._10 == n._10 && m._20 == n._20 && m._30 == n._30 && m._01 == n._01 && m._11 == n._11 && m._21 == n._21 && m._31 == n._31
			&& m._02 == n._02 && m._12 == n._12 && m._22 == n._22 && m._32 == n._32 && m._03 == n._03 && m._13 == n._13 && m._23 == n._23 && m._33 == n._33;
	}

	@:op(a != b)
	static inline function notEqual(m:Mat4, n:Mat4):Bool
		return !equal(m, n);
	#end // !macro

	/**
		Copies matrix elements in column-major order into a type that supports array-write access
	**/
	@:overload(function<T>(arrayLike:T, index:Int):T {})
	public macro function copyIntoArray(self:haxe.macro.Expr.ExprOf<Mat4>, array:haxe.macro.Expr.ExprOf<ArrayAccess<FastFloat>>,
			index:haxe.macro.Expr.ExprOf<Int>) {
		return macro {
			var self = $self;
			var array = $array;
			var i:Int = $index;
			self[0].copyIntoArray(array, i);
			self[1].copyIntoArray(array, i + 4);
			self[2].copyIntoArray(array, i + 8);
			self[3].copyIntoArray(array, i + 12);
			array;
		}
	}

	/**
		Copies matrix elements in column-major order from a type that supports array-read access
	**/
	@:overload(function<T>(arrayLike:T, index:Int):Mat4 {})
	public macro function copyFromArray(self:haxe.macro.Expr.ExprOf<Mat4>, array:haxe.macro.Expr.ExprOf<ArrayAccess<FastFloat>>,
			index:haxe.macro.Expr.ExprOf<Int>) {
		return macro {
			var self = $self;
			var array = $array;
			var i:Int = $index;
			self[0].copyFromArray(array, i);
			self[1].copyFromArray(array, i + 4);
			self[2].copyFromArray(array, i + 8);
			self[3].copyFromArray(array, i + 12);
			self;
		}
	}

	// static macros

	@:overload(function<T>(arrayLike:T, index:Int):T {})
	public static macro function fromArray(array:ExprOf<ArrayAccess<FastFloat>>, index:ExprOf<Int>):ExprOf<Mat4> {
		return macro {
			var array = $array;
			var i:Int = $index;
			new Mat4(array[0 + i], array[1 + i], array[2 + i], array[3 + i], array[4 + i], array[5 + i], array[6 + i], array[7 + i], array[8 + i],
				array[9 + i], array[10 + i], array[11 + i], array[12 + i], array[13 + i], array[14 + i], array[15 + i]);
		}
	}
}
