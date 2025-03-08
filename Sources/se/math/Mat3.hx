package se.math;

import kha.math.FastMatrix3 as KhaMat3;

@:forward.new
@:forward(_00, _10, _20, _01, _11, _21, _02, _12, _22)
extern abstract Mat3(KhaMat3) from KhaMat3 to KhaMat3 {
	public static inline function identity():Mat3 {
		return KhaMat3.identity();
	}

	public static inline function empty():Mat3 {
		return KhaMat3.empty();
	}

	public static inline function translation(x:Float, y:Float):Mat3 {
		return KhaMat3.translation(x, y);
	}

	public static inline function scale(x:Float, y:Float):Mat3 {
		return KhaMat3.scale(x, y);
	}

	public static inline function rotation(angle:Float):Mat3 {
		return KhaMat3.rotation(angle);
	}

	public static inline function orthogonalProjection(left:Float, right:Float, bottom:Float, top:Float):Mat3 {
		var tx = -(right + left) / (right - left);
		var ty = -(top + bottom) / (top - bottom);

		return new Mat3(2 / (right - left), 0, tx, 0, 2.0 / (top - bottom), ty, 0, 0, 1);
	}

	public static inline function lookAt(eye:Vec2, at:Vec2, up:Vec2):Mat3 {
		var zaxis = (at - eye).normalize();
		return new Mat3(-zaxis.y, zaxis.x, zaxis.y * eye.x - zaxis.x * eye.y, -zaxis.x, -zaxis.y, zaxis.x * eye.x + zaxis.y * eye.y, 0, 0, 1);
	}

	public inline function set(a00:Float, a10:Float, a20:Float, a01:Float, a11:Float, a21:Float, a02:Float, a12:Float, a22:Float) {
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

	public inline function copyFrom(v:Mat3) {
		this.setFrom(v);
		return this;
	}

	public inline function clone():Mat3 {
		return new Mat3(this._00, this._10, this._20, this._01, this._11, this._21, this._02, this._12, this._22);
	}

	public inline function matrixCompMult(n:Mat3):Mat3 {
		var n:KhaMat3 = n;
		return new Mat3(this._00 * n._00, this._10 * n._10, this._20 * n._20, this._01 * n._01, this._11 * n._11, this._21 * n._21, this._02 * n._02,
			this._12 * n._12, this._22 * n._22);
	}

	// extended methods

	public inline function transpose():Mat3 {
		return new Mat3(this._00, this._01, this._02, this._10, this._11, this._12, this._20, this._21, this._22);
	}

	public inline function determinant():Float {
		var m = this;
		return (m._00 * (m._22 * m._11 - m._21 * m._12) + m._10 * (-m._22 * m._01 + m._21 * m._02) + m._20 * (m._12 * m._01 - m._11 * m._02));
	}

	public inline function inverse():Mat3 {
		var m = this;
		var b01 = m._22 * m._11 - m._21 * m._12;
		var b11 = -m._22 * m._01 + m._21 * m._02;
		var b21 = m._12 * m._01 - m._11 * m._02;

		// determinant
		var det = m._00 * b01 + m._10 * b11 + m._20 * b21;

		var f = 1.0 / det;

		return new Mat3(b01 * f, (-m._22 * m._10 + m._20 * m._12) * f, (m._21 * m._10 - m._20 * m._11) * f, b11 * f, (m._22 * m._00 - m._20 * m._02) * f,
			(-m._21 * m._00 + m._20 * m._01) * f, b21 * f, (-m._12 * m._00 + m._10 * m._02) * f, (m._11 * m._00 - m._10 * m._01) * f);
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

	@:op(-a)
	static private inline function neg(m:Mat3) {
		var m:KhaMat3 = m;
		return new Mat3(-m._00, -m._10, -m._20, -m._01, -m._11, -m._21, -m._02, -m._12, -m._22);
	}

	@:op(++a)
	static private inline function prefixIncrement(m:Mat3) {
		var _m:KhaMat3 = m;
		++_m._00;
		++_m._10;
		++_m._20;
		++_m._01;
		++_m._11;
		++_m._21;
		++_m._02;
		++_m._12;
		++_m._22;
		return m.clone();
	}

	@:op(--a)
	static private inline function prefixDecrement(m:Mat3) {
		var _m:KhaMat3 = m;
		--_m._00;
		--_m._10;
		--_m._20;
		--_m._01;
		--_m._11;
		--_m._21;
		--_m._02;
		--_m._12;
		--_m._22;
		return m.clone();
	}

	@:op(a++)
	static private inline function postfixIncrement(m:Mat3) {
		var ret = m.clone();
		var m:KhaMat3 = m;
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
	static private inline function postfixDecrement(m:Mat3) {
		var ret = m.clone();
		var m:KhaMat3 = m;
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
	static private inline function mulEq(a:Mat3, b:Mat3):Mat3
		return a.copyFrom(a * b);

	@:op(a *= b)
	static private inline function mulEqScalar(a:Mat3, f:Float):Mat3
		return a.copyFrom(a * f);

	@:op(a /= b)
	static private inline function divEq(a:Mat3, b:Mat3):Mat3
		return a.copyFrom(a / b);

	@:op(a /= b)
	static private inline function divEqScalar(a:Mat3, f:Float):Mat3
		return a.copyFrom(a / f);

	@:op(a += b)
	static private inline function addEq(a:Mat3, b:Mat3):Mat3
		return a.copyFrom(a + b);

	@:op(a += b)
	static private inline function addEqScalar(a:Mat3, f:Float):Mat3
		return a.copyFrom(a + f);

	@:op(a -= b)
	static private inline function subEq(a:Mat3, b:Mat3):Mat3
		return a.copyFrom(a - b);

	@:op(a -= b)
	static private inline function subEqScalar(a:Mat3, f:Float):Mat3
		return a.copyFrom(a - f);

	@:op(a + b)
	static private inline function add(m:Mat3, n:Mat3):Mat3 {
		var m:KhaMat3 = m;
		var n:KhaMat3 = n;
		return new Mat3(m._00
			+ n._00, m._10
			+ n._10, m._20
			+ n._20, m._01
			+ n._01, m._11
			+ n._11, m._21
			+ n._21, m._02
			+ n._02, m._12
			+ n._12, m._22
			+ n._22);
	}

	@:op(a + b) @:commutative
	static private inline function addScalar(m:Mat3, f:Float):Mat3 {
		var m:KhaMat3 = m;
		return new Mat3(m._00 + f, m._10 + f, m._20 + f, m._01 + f, m._11 + f, m._21 + f, m._02 + f, m._12 + f, m._22 + f);
	}

	@:op(a - b)
	static private inline function sub(m:Mat3, n:Mat3):Mat3 {
		var m:KhaMat3 = m;
		var n:KhaMat3 = n;
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
	static private inline function subScalar(m:Mat3, f:Float):Mat3 {
		var m:KhaMat3 = m;
		return new Mat3(m._00 - f, m._10 - f, m._20 - f, m._01 - f, m._11 - f, m._21 - f, m._02 - f, m._12 - f, m._22 - f);
	}

	@:op(a - b)
	static private inline function subScalarInv(f:Float, m:Mat3):Mat3 {
		var m:KhaMat3 = m;
		return new Mat3(f - m._00, f - m._10, f - m._20, f - m._01, f - m._11, f - m._21, f - m._02, f - m._12, f - m._22);
	}

	@:op(a * b)
	static private inline function mul(m:Mat3, n:Mat3):Mat3 {
		var m:KhaMat3 = m;
		var n:KhaMat3 = n;
		return new Mat3(m._00 * n._00
			+ m._01 * n._10
			+ m._02 * n._20, m._10 * n._00
			+ m._11 * n._10
			+ m._12 * n._20,
			m._20 * n._00
			+ m._21 * n._10
			+ m._22 * n._20, m._00 * n._01
			+ m._01 * n._11
			+ m._02 * n._21, m._10 * n._01
			+ m._11 * n._11
			+ m._12 * n._21,
			m._20 * n._01
			+ m._21 * n._11
			+ m._22 * n._21, m._00 * n._02
			+ m._01 * n._12
			+ m._02 * n._22, m._10 * n._02
			+ m._11 * n._12
			+ m._12 * n._22,
			m._20 * n._02
			+ m._21 * n._12
			+ m._22 * n._22);
	}

	@:op(a * b)
	static private inline function postMulVec2(m:Mat3, v:Vec2):Vec2 {
		return (m : KhaMat3).multvec(v);
	}

	@:op(a * b)
	static private inline function postMulVec3(m:Mat3, v:Vec3):Vec3 {
		var m:KhaMat3 = m;
		return new Vec3(m._00 * v.x
			+ m._01 * v.y
			+ m._02 * v.z, m._10 * v.x
			+ m._11 * v.y
			+ m._12 * v.z, m._20 * v.x
			+ m._21 * v.y
			+ m._22 * v.z);
	}

	@:op(a * b)
	static private inline function preMulVec3(v:Vec3, m:Mat3):Vec3 {
		var m:KhaMat3 = m;
		return new Vec3(v.dot(new Vec3(m._00, m._10, m._20)), v.dot(new Vec3(m._01, m._11, m._21)), v.dot(new Vec3(m._02, m._12, m._22)));
	}

	@:op(a * b) @:commutative
	static private inline function mulScalar(m:Mat3, f:Float):Mat3 {
		var m:KhaMat3 = m;
		return new Mat3(m._00 * f, m._10 * f, m._20 * f, m._01 * f, m._11 * f, m._21 * f, m._02 * f, m._12 * f, m._22 * f);
	}

	@:op(a / b)
	static private inline function div(m:Mat3, n:Mat3):Mat3
		return m.matrixCompMult(1.0 / n);

	@:op(a / b)
	static private inline function divScalar(m:Mat3, f:Float):Mat3 {
		var m:KhaMat3 = m;
		return new Mat3(m._00 / f, m._10 / f, m._20 / f, m._01 / f, m._11 / f, m._21 / f, m._02 / f, m._12 / f, m._22 / f);
	}

	@:op(a / b)
	static private inline function divScalarInv(f:Float, m:Mat3):Mat3 {
		var m:KhaMat3 = m;
		return new Mat3(f / m._00, f / m._10, f / m._20, f / m._01, f / m._11, f / m._21, f / m._02, f / m._12, f / m._22);
	}

	@:op(a == b)
	static private inline function equal(m:Mat3, n:Mat3):Bool {
		var m:KhaMat3 = m;
		var n:KhaMat3 = n;
		return m._00 == n._00 && m._10 == n._10 && m._20 == n._20 && m._01 == n._01 && m._11 == n._11 && m._21 == n._21 && m._02 == n._02 && m._12 == n._12
			&& m._22 == n._22;
	}

	@:op(a != b)
	static private inline function notEqual(m:Mat3, n:Mat3):Bool
		return !equal(m, n);

	/**
		Copies matrix elements in column-major order into a type that supports array-write access
	**/
	@:overload(function<T>(arrayLike:T, index:Int):T {})
	public macro function copyIntoArray(self:haxe.macro.Expr.ExprOf<Mat3>, array:haxe.macro.Expr.ExprOf<ArrayAccess<Float>>,
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
	public macro function copyFromArray(self:haxe.macro.Expr.ExprOf<Mat3>, array:haxe.macro.Expr.ExprOf<ArrayAccess<Float>>,
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
	public static macro function fromArray(array:ExprOf<ArrayAccess<Float>>, index:ExprOf<Int>):ExprOf<Mat3> {
		return macro {
			var array = $array;
			var i:Int = $index;
			new Mat3(array[0 + i], array[1 + i], array[2 + i], array[3 + i], array[4 + i], array[5 + i], array[6 + i], array[7 + i], array[8 + i]);
		}
	}
}
