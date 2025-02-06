package s2d.math;

import kha.FastFloat;
import kha.math.FastMatrix3;
// s2d
import s2d.math.VectorMath;

@:forward(_00, _10, _20, _01, _11, _21, _02, _12, _22)
abstract Mat3(FastMatrix3) from FastMatrix3 to FastMatrix3 {
	#if !macro
	public var translationX(get, set):FastFloat;
	public var translationY(get, set):FastFloat;
	public var translation(get, set):Vec2;
	public var scaleX(get, set):FastFloat;
	public var scaleY(get, set):FastFloat;
	public var scale(get, set):Vec2;
	public var rotation(get, set):FastFloat;

	public inline function new(a00:FastFloat, a10:FastFloat, a20:FastFloat, a01:FastFloat, a11:FastFloat, a21:FastFloat, a02:FastFloat, a12:FastFloat,
			a22:FastFloat) {
		this = new FastMatrix3(a00, a10, a20, a01, a11, a21, a02, a12, a22);
	}

	public static inline function identity():Mat3 {
		return FastMatrix3.identity();
	}

	public static inline function orthogonalProjection(left:FastFloat, right:FastFloat, bottom:FastFloat, top:FastFloat):Mat3 {
		var tx = -(right + left) / (right - left);
		var ty = -(top + bottom) / (top - bottom);

		return new Mat3(2 / (right - left), 0, tx, 0, 2.0 / (top - bottom), ty, 0, 0, 1);
	}

	public static inline function lookAt(eye:Vec2, at:Vec2, up:Vec2):Mat3 {
		var zaxis = normalize(at - eye);
		return new Mat3(-zaxis.y, zaxis.x, zaxis.y * eye.x - zaxis.x * eye.y, -zaxis.x, -zaxis.y, zaxis.x * eye.x + zaxis.y * eye.y, 0, 0, 1);
	}

	public static inline function translationMatrix(x:FastFloat, y:FastFloat):Mat3 {
		return FastMatrix3.translation(x, y);
	}

	public static inline function scaleMatrix(x:FastFloat, y:FastFloat):Mat3 {
		return FastMatrix3.scale(x, y);
	}

	public static inline function rotationMatrix(angle:FastFloat):Mat3 {
		return FastMatrix3.rotation(angle);
	}

	public inline function pushTranslation(value:Vec2):Void {
		translation += value;
	}

	public inline function pushScale(value:Vec2):Void {
		scale *= value;
	}

	public inline function pushRotation(value:FastFloat):Void {
		rotation += value;
	}

	inline function get_translationX():FastFloat {
		return this._20;
	}

	inline function set_translationX(value:FastFloat):FastFloat {
		this._20 = value;
		return value;
	}

	inline function get_translationY():FastFloat {
		return this._21;
	}

	inline function set_translationY(value:FastFloat):FastFloat {
		this._21 = value;
		return value;
	}

	inline function get_translation():Vec2 {
		return vec2(translationX, translationY);
	}

	inline function set_translation(value:Vec2):Vec2 {
		translationX = value.x;
		translationY = value.y;
		return value;
	}

	inline function get_scaleX():FastFloat {
		return sqrt(this._00 * this._00 + this._10 * this._10);
	}

	inline function set_scaleX(value:FastFloat):FastFloat {
		var xt = normalize(vec2(this._00, this._10)) * value;
		this._00 = xt.x;
		this._10 = xt.y;
		return value;
	}

	inline function get_scaleY():FastFloat {
		return sqrt(this._01 * this._01 + this._11 * this._11);
	}

	inline function set_scaleY(value:FastFloat):FastFloat {
		var yt = normalize(vec2(this._01, this._11)) * value;
		this._01 = yt.x;
		this._11 = yt.y;
		return value;
	}

	inline function get_scale():Vec2 {
		return vec2(scaleX, scaleY);
	}

	inline function set_scale(value:Vec2):Vec2 {
		scaleX = value.x;
		scaleY = value.y;
		return value;
	}

	inline function get_rotation():FastFloat {
		return atan2(this._10, this._00);
	}

	inline function set_rotation(value:FastFloat):FastFloat {
		var sx = scaleX;
		var sy = scaleY;
		var c = cos(value);
		var s = sin(value);
		this._00 = c * sx;
		this._10 = s * sx;
		this._01 = -s * sy;
		this._11 = c * sy;
		return value;
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

	public inline function copyFrom(v:Mat3) {
		this.setFrom(v);
		return this;
	}

	public inline function clone():Mat3 {
		return new Mat3(this._00, this._10, this._20, this._01, this._11, this._21, this._02, this._12, this._22);
	}

	public inline function matrixCompMult(n:Mat3):Mat3 {
		var n:FastMatrix3 = n;
		return new Mat3(this._00 * n._00, this._10 * n._10, this._20 * n._20, this._01 * n._01, this._11 * n._11, this._21 * n._21, this._02 * n._02,
			this._12 * n._12, this._22 * n._22);
	}

	// extended methods

	public inline function transpose():Mat3 {
		return new Mat3(this._00, this._01, this._02, this._10, this._11, this._12, this._20, this._21, this._22);
	}

	public inline function determinant():FastFloat {
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
	static inline function neg(m:Mat3) {
		var m:FastMatrix3 = m;
		return new Mat3(-m._00, -m._10, -m._20, -m._01, -m._11, -m._21, -m._02, -m._12, -m._22);
	}

	@:op(++a)
	static inline function prefixIncrement(m:Mat3) {
		var _m:FastMatrix3 = m;
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
	static inline function prefixDecrement(m:Mat3) {
		var _m:FastMatrix3 = m;
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
		var m:FastMatrix3 = m;
		var n:FastMatrix3 = n;
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
		var m:FastMatrix3 = m;
		var n:FastMatrix3 = n;
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
	static inline function postMulVec2(m:Mat3, v:Vec2):Vec2 {
		return (m : FastMatrix3).multvec(v);
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
		var m:FastMatrix3 = m;
		return new Vec3(v.dot(new Vec3(m._00, m._10, m._20)), v.dot(new Vec3(m._01, m._11, m._21)), v.dot(new Vec3(m._02, m._12, m._22)));
	}

	@:op(a * b) @:commutative
	static inline function mulScalar(m:Mat3, f:FastFloat):Mat3 {
		var m:FastMatrix3 = m;
		return new Mat3(m._00 * f, m._10 * f, m._20 * f, m._01 * f, m._11 * f, m._21 * f, m._02 * f, m._12 * f, m._22 * f);
	}

	@:op(a / b)
	static inline function div(m:Mat3, n:Mat3):Mat3
		return m.matrixCompMult(1.0 / n);

	@:op(a / b)
	static inline function divScalar(m:Mat3, f:FastFloat):Mat3 {
		var m:FastMatrix3 = m;
		return new Mat3(m._00 / f, m._10 / f, m._20 / f, m._01 / f, m._11 / f, m._21 / f, m._02 / f, m._12 / f, m._22 / f);
	}

	@:op(a / b)
	static inline function divScalarInv(f:FastFloat, m:Mat3):Mat3 {
		var m:FastMatrix3 = m;
		return new Mat3(f / m._00, f / m._10, f / m._20, f / m._01, f / m._11, f / m._21, f / m._02, f / m._12, f / m._22);
	}

	@:op(a == b)
	static inline function equal(m:Mat3, n:Mat3):Bool {
		var m:FastMatrix3 = m;
		var n:FastMatrix3 = n;
		return m._00 == n._00 && m._10 == n._10 && m._20 == n._20 && m._01 == n._01 && m._11 == n._11 && m._21 == n._21 && m._02 == n._02 && m._12 == n._12
			&& m._22 == n._22;
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
