package s2d.math;

import kha.FastFloat;
import kha.math.FastMatrix4;
// s2d
import s2d.math.SMath;

abstract Mat4(FastMatrix4) from FastMatrix4 to FastMatrix4 {
	extern public static inline function identity():Mat4 {
		return FastMatrix4.identity();
	}

	extern public static inline function empty():Mat4 {
		return FastMatrix4.empty();
	}

	extern public static inline function orthogonalProjection(left:FastFloat, right:FastFloat, bottom:FastFloat, top:FastFloat, zn:FastFloat, zf:FastFloat):Mat4 {
		return FastMatrix4.orthogonalProjection(left, right, bottom, top, zn, zf);
	}

	extern public static inline function perspectiveProjection(fovY:FastFloat, aspect:FastFloat, zn:FastFloat, zf:FastFloat):Mat4 {
		return FastMatrix4.perspectiveProjection(fovY, aspect, zn, zf);
	}

	extern public static inline function lookAt(eye:Vec3, at:Vec3, up:Vec3):Mat4 {
		return FastMatrix4.lookAt(eye, at, up);
	}

	#if !macro
	public var translationX(get, set):FastFloat;
	public var translationY(get, set):FastFloat;
	public var translationZ(get, set):FastFloat;
	public var translation(get, set):Vec3;
	public var scaleX(get, set):FastFloat;
	public var scaleY(get, set):FastFloat;
	public var scale(get, set):Vec2;
	public var rotation(get, set):FastFloat;

	public inline function new(a00:FastFloat, a01:FastFloat, a02:FastFloat, a03:FastFloat, a10:FastFloat, a11:FastFloat, a12:FastFloat, a13:FastFloat, a20:FastFloat, a21:FastFloat, a22:FastFloat,
			a23:FastFloat, a30:FastFloat, a31:FastFloat, a32:FastFloat, a33:FastFloat) {
		this = new FastMatrix4(a00, a01, a02, a03, a10, a11, a12, a13, a20, a21, a22, a23, a30, a31, a32, a33);
	}

	public inline function pushTranslation(x:FastFloat, y:FastFloat, ?z:FastFloat = 0.0):Void {
		this._30 += x;
		this._31 += y;
		this._32 += z;
	}

	public inline function pushScale(x:FastFloat, y:FastFloat):Void {
		this._00 *= x;
		this._10 *= x;
		this._20 *= x;
		this._01 *= y;
		this._11 *= y;
		this._21 *= y;
	}

	public inline function pushRotation(angle:FastFloat):Void {
		rotation += angle;
	}

	inline function get_translationX():FastFloat {
		return this._30;
	}

	inline function set_translationX(value:FastFloat):FastFloat {
		this._30 = value;
		return value;
	}

	inline function get_translationY():FastFloat {
		return this._31;
	}

	inline function set_translationY(value:FastFloat):FastFloat {
		this._31 = value;
		return value;
	}

	inline function get_translationZ():FastFloat {
		return this._32;
	}

	inline function set_translationZ(value:FastFloat):FastFloat {
		this._32 = value;
		return value;
	}

	inline function get_translation():Vec3 {
		return {
			x: translationX,
			y: translationY,
			z: translationZ
		};
	}

	inline function set_translation(value:Vec3):Vec3 {
		translationX = value.x;
		translationY = value.y;
		translationZ = value.z;
		return value;
	}

	inline function get_scaleX():FastFloat {
		return Math.sqrt(this._00 * this._00 + this._10 * this._10 + this._20 * this._20);
	}

	inline function set_scaleX(value:FastFloat):FastFloat {
		var sx = scaleX;
		this._00 *= value / sx;
		this._10 *= value / sx;
		this._20 *= value / sx;
		return value;
	}

	inline function get_scaleY():FastFloat {
		return Math.sqrt(this._01 * this._01 + this._11 * this._11 + this._21 * this._21);
	}

	inline function set_scaleY(value:FastFloat):FastFloat {
		var sy = scaleY;
		this._01 *= value / sy;
		this._11 *= value / sy;
		this._21 *= value / sy;
		return value;
	}

	inline function get_scale():Vec2 {
		return {
			x: scaleX,
			y: scaleY
		};
	}

	inline function set_scale(value:Vec2):Vec2 {
		scaleX = value.x;
		scaleY = value.y;
		return value;
	}

	inline function get_rotation():FastFloat {
		return Math.atan2(this._10, this._00);
	}

	inline function set_rotation(value:FastFloat):FastFloat {
		var angle = value;
		var sx = scaleX;
		var sy = scaleY;
		var ca = Math.cos(angle);
		var cs = Math.sin(angle);

		this._00 = ca * sx;
		this._10 = cs * sx;
		this._01 = -cs * sy;
		this._11 = ca * sy;
		return value;
	}

	public inline function set(a00:FastFloat, a01:FastFloat, a02:FastFloat, a03:FastFloat, a10:FastFloat, a11:FastFloat, a12:FastFloat, a13:FastFloat, a20:FastFloat, a21:FastFloat, a22:FastFloat,
			a23:FastFloat, a30:FastFloat, a31:FastFloat, a32:FastFloat, a33:FastFloat) {
		this._00 = a00;
		this._01 = a01;
		this._02 = a02;
		this._03 = a03;
		this._10 = a10;
		this._11 = a11;
		this._12 = a12;
		this._13 = a13;
		this._20 = a20;
		this._21 = a21;
		this._22 = a22;
		this._23 = a23;
		this._30 = a30;
		this._31 = a31;
		this._32 = a32;
		this._33 = a33;
	}

	public inline function copyFrom(m:Mat4) {
		var m:FastMatrix4 = m;
		this._00 = m._00;
		this._01 = m._01;
		this._02 = m._02;
		this._03 = m._03;
		this._10 = m._10;
		this._11 = m._11;
		this._12 = m._12;
		this._13 = m._13;
		this._20 = m._20;
		this._21 = m._21;
		this._22 = m._22;
		this._23 = m._23;
		this._30 = m._30;
		this._31 = m._31;
		this._32 = m._32;
		this._33 = m._33;
		return this;
	}

	public inline function clone():Mat4 {
		return new Mat4(this._00, this._01, this._02, this._03, this._10, this._11, this._12, this._13, this._20, this._21, this._22, this._23, this._30,
			this._31, this._32, this._33);
	}

	public inline function matrixCompMult(n:Mat4):Mat4 {
		var m = this;
		var n:FastMatrix4 = n;
		return new Mat4(m._00 * n._00, m._01 * n._01, m._02 * n._02, m._03 * n._03, m._10 * n._10, m._11 * n._11, m._12 * n._12, m._13 * n._13, m._20 * n._20,
			m._21 * n._21, m._22 * n._22, m._23 * n._23, m._30 * n._30, m._31 * n._31, m._32 * n._32, m._33 * n._33);
	}

	// extended methods

	public inline function transpose():Mat4 {
		var m = this;
		return new Mat4(m._00, m._10, m._20, m._30, m._01, m._11, m._21, m._31, m._02, m._12, m._22, m._32, m._03, m._13, m._23, m._33);
	}

	public inline function determinant():FastFloat {
		var m = this;
		var b0 = m._00 * m._11 - m._01 * m._10;
		var b1 = m._00 * m._12 - m._02 * m._10;
		var b2 = m._01 * m._12 - m._02 * m._11;
		var b3 = m._20 * m._31 - m._21 * m._30;
		var b4 = m._20 * m._32 - m._22 * m._30;
		var b5 = m._21 * m._32 - m._22 * m._31;
		var b6 = m._00 * b5 - m._01 * b4 + m._02 * b3;
		var b7 = m._10 * b5 - m._11 * b4 + m._12 * b3;
		var b8 = m._20 * b2 - m._21 * b1 + m._22 * b0;
		var b9 = m._30 * b2 - m._31 * b1 + m._32 * b0;
		return m._13 * b6 - m._03 * b7 + m._33 * b8 - m._23 * b9;
	}

	public inline function inverse():Mat4 {
		var m = this;
		var b00 = m._00 * m._11 - m._01 * m._10;
		var b01 = m._00 * m._12 - m._02 * m._10;
		var b02 = m._00 * m._13 - m._03 * m._10;
		var b03 = m._01 * m._12 - m._02 * m._11;
		var b04 = m._01 * m._13 - m._03 * m._11;
		var b05 = m._02 * m._13 - m._03 * m._12;
		var b06 = m._20 * m._31 - m._21 * m._30;
		var b07 = m._20 * m._32 - m._22 * m._30;
		var b08 = m._20 * m._33 - m._23 * m._30;
		var b09 = m._21 * m._32 - m._22 * m._31;
		var b10 = m._21 * m._33 - m._23 * m._31;
		var b11 = m._22 * m._33 - m._23 * m._32;

		// determinant
		var det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;

		var f = 1.0 / det;

		return new Mat4((m._11 * b11 - m._12 * b10 + m._13 * b09) * f, (m._02 * b10 - m._01 * b11 - m._03 * b09) * f,
			(m._31 * b05 - m._32 * b04 + m._33 * b03) * f, (m._22 * b04 - m._21 * b05 - m._23 * b03) * f, (m._12 * b08 - m._10 * b11 - m._13 * b07) * f,
			(m._00 * b11 - m._02 * b08 + m._03 * b07) * f, (m._32 * b02 - m._30 * b05 - m._33 * b01) * f, (m._20 * b05 - m._22 * b02 + m._23 * b01) * f,
			(m._10 * b10 - m._11 * b08 + m._13 * b06) * f, (m._01 * b08 - m._00 * b10 - m._03 * b06) * f, (m._30 * b04 - m._31 * b02 + m._33 * b00) * f,
			(m._21 * b02 - m._20 * b04 - m._23 * b00) * f, (m._11 * b07 - m._10 * b09 - m._12 * b06) * f, (m._00 * b09 - m._01 * b07 + m._02 * b06) * f,
			(m._31 * b01 - m._30 * b03 - m._32 * b00) * f, (m._20 * b03 - m._21 * b01 + m._22 * b00) * f);
	}

	public inline function adjoint():Mat4 {
		var m = this;
		var b00 = m._00 * m._11 - m._01 * m._10;
		var b01 = m._00 * m._12 - m._02 * m._10;
		var b02 = m._00 * m._13 - m._03 * m._10;
		var b03 = m._01 * m._12 - m._02 * m._11;
		var b04 = m._01 * m._13 - m._03 * m._11;
		var b05 = m._02 * m._13 - m._03 * m._12;
		var b06 = m._20 * m._31 - m._21 * m._30;
		var b07 = m._20 * m._32 - m._22 * m._30;
		var b08 = m._20 * m._33 - m._23 * m._30;
		var b09 = m._21 * m._32 - m._22 * m._31;
		var b10 = m._21 * m._33 - m._23 * m._31;
		var b11 = m._22 * m._33 - m._23 * m._32;
		return new Mat4(m._11 * b11
			- m._12 * b10
			+ m._13 * b09, m._02 * b10
			- m._01 * b11
			- m._03 * b09, m._31 * b05
			- m._32 * b04
			+ m._33 * b03,
			m._22 * b04
			- m._21 * b05
			- m._23 * b03, m._12 * b08
			- m._10 * b11
			- m._13 * b07, m._00 * b11
			- m._02 * b08
			+ m._03 * b07,
			m._32 * b02
			- m._30 * b05
			- m._33 * b01, m._20 * b05
			- m._22 * b02
			+ m._23 * b01, m._10 * b10
			- m._11 * b08
			+ m._13 * b06,
			m._01 * b08
			- m._00 * b10
			- m._03 * b06, m._30 * b04
			- m._31 * b02
			+ m._33 * b00, m._21 * b02
			- m._20 * b04
			- m._23 * b00,
			m._11 * b07
			- m._10 * b09
			- m._12 * b06, m._00 * b09
			- m._01 * b07
			+ m._02 * b06, m._31 * b01
			- m._30 * b03
			- m._32 * b00,
			m._20 * b03
			- m._21 * b01
			+ m._22 * b00);
	}

	public inline function toString() {
		return 'mat4(' + '${this._00}, ${this._01}, ${this._02}, ${this._03}, ' + '${this._10}, ${this._11}, ${this._12}, ${this._13}, '
			+ '${this._20}, ${this._21}, ${this._22}, ${this._23}, ' + '${this._30}, ${this._31}, ${this._32}, ${this._33}' + ')';
	}

	@:op([])
	inline function arrayRead(i:Int):Vec4
		return switch i {
			case 0: {
					x: this._00,
					y: this._01,
					z: this._02,
					w: this._03
				}
			case 1: {
					x: this._10,
					y: this._11,
					z: this._12,
					w: this._13
				}
			case 2: {
					x: this._20,
					y: this._21,
					z: this._22,
					w: this._23
				}
			case 3: {
					x: this._30,
					y: this._31,
					z: this._32,
					w: this._33
				}
			default: null;
		}

	@:op([])
	inline function arrayWrite(i:Int, v:Vec4)
		return switch i {
			case 0: {
					this._00 = v.x;
					this._01 = v.y;
					this._02 = v.z;
					this._03 = v.w;
				}
			case 1: {
					this._10 = v.x;
					this._11 = v.y;
					this._12 = v.z;
					this._13 = v.w;
				}
			case 2: {
					this._20 = v.x;
					this._21 = v.y;
					this._22 = v.z;
					this._23 = v.w;
				}
			case 3: {
					this._30 = v.x;
					this._31 = v.y;
					this._32 = v.z;
					this._33 = v.w;
				}
			default: null;
		}

	@:op(-a)
	static inline function neg(m:Mat4) {
		var m:FastMatrix4 = m;
		return new Mat4(-m._00,
			-m._01,
			-m._02,
			-m._03,
			-m._10,
			-m._11,
			-m._12,
			-m._13,
			-m._20,
			-m._21,
			-m._22,
			-m._23,
			-m._30,
			-m._31,
			-m._32,
			-m._33);
	}

	@:op(++a)
	static inline function prefixIncrement(m:Mat4) {
		++m[0];
		++m[1];
		++m[2];
		++m[3];
		return m.clone();
	}

	@:op(--a)
	static inline function prefixDecrement(m:Mat4) {
		--m[0];
		--m[1];
		--m[2];
		--m[3];
		return m.clone();
	}

	@:op(a++)
	static inline function postfixIncrement(m:Mat4) {
		var ret = m.clone();
		++m[0];
		++m[1];
		++m[2];
		++m[3];
		return ret;
	}

	@:op(a--)
	static inline function postfixDecrement(m:Mat4) {
		var ret = m.clone();
		--m[0];
		--m[1];
		--m[2];
		--m[3];
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
		var m:FastMatrix4 = m;
		var n:FastMatrix4 = n;
		return new Mat4(m._00
			+ n._00, m._01
			+ n._01, m._02
			+ n._02, m._03
			+ n._03, m._10
			+ n._10, m._11
			+ n._11, m._12
			+ n._12, m._13
			+ n._13, m._20
			+ n._20,
			m._21
			+ n._21, m._22
			+ n._22, m._23
			+ n._23, m._30
			+ n._30, m._31
			+ n._31, m._32
			+ n._32, m._33
			+ n._33);
	}

	@:op(a + b) @:commutative
	static inline function addScalar(m:Mat4, f:FastFloat):Mat4 {
		var m:FastMatrix4 = m;
		return new Mat4(m._00
			+ f, m._01
			+ f, m._02
			+ f, m._03
			+ f, m._10
			+ f, m._11
			+ f, m._12
			+ f, m._13
			+ f, m._20
			+ f, m._21
			+ f, m._22
			+ f, m._23
			+ f,
			m._30
			+ f, m._31
			+ f, m._32
			+ f, m._33
			+ f);
	}

	@:op(a - b)
	static inline function sub(m:Mat4, n:Mat4):Mat4 {
		var m:FastMatrix4 = m;
		var n:FastMatrix4 = n;
		return new Mat4(m._00
			- n._00, m._01
			- n._01, m._02
			- n._02, m._03
			- n._03, m._10
			- n._10, m._11
			- n._11, m._12
			- n._12, m._13
			- n._13, m._20
			- n._20,
			m._21
			- n._21, m._22
			- n._22, m._23
			- n._23, m._30
			- n._30, m._31
			- n._31, m._32
			- n._32, m._33
			- n._33);
	}

	@:op(a - b)
	static inline function subScalar(m:Mat4, f:FastFloat):Mat4 {
		var m:FastMatrix4 = m;
		return new Mat4(m._00
			- f, m._01
			- f, m._02
			- f, m._03
			- f, m._10
			- f, m._11
			- f, m._12
			- f, m._13
			- f, m._20
			- f, m._21
			- f, m._22
			- f, m._23
			- f,
			m._30
			- f, m._31
			- f, m._32
			- f, m._33
			- f);
	}

	@:op(a - b)
	static inline function subScalarInv(f:FastFloat, m:Mat4):Mat4 {
		var m:FastMatrix4 = m;
		return new Mat4(f
			- m._00, f
			- m._01, f
			- m._02, f
			- m._03, f
			- m._10, f
			- m._11, f
			- m._12, f
			- m._13, f
			- m._20, f
			- m._21, f
			- m._22, f
			- m._23,
			f
			- m._30, f
			- m._31, f
			- m._32, f
			- m._33);
	}

	@:op(a * b)
	static inline function mul(m:Mat4, n:Mat4):Mat4 {
		var m:FastMatrix4 = m;
		var n:FastMatrix4 = n;
		return new Mat4(m._00 * n._00
			+ m._10 * n._01
			+ m._20 * n._02
			+ m._30 * n._03, m._01 * n._00
			+ m._11 * n._01
			+ m._21 * n._02
			+ m._31 * n._03,
			m._02 * n._00
			+ m._12 * n._01
			+ m._22 * n._02
			+ m._32 * n._03, m._03 * n._00
			+ m._13 * n._01
			+ m._23 * n._02
			+ m._33 * n._03,
			m._00 * n._10
			+ m._10 * n._11
			+ m._20 * n._12
			+ m._30 * n._13, m._01 * n._10
			+ m._11 * n._11
			+ m._21 * n._12
			+ m._31 * n._13,
			m._02 * n._10
			+ m._12 * n._11
			+ m._22 * n._12
			+ m._32 * n._13, m._03 * n._10
			+ m._13 * n._11
			+ m._23 * n._12
			+ m._33 * n._13,
			m._00 * n._20
			+ m._10 * n._21
			+ m._20 * n._22
			+ m._30 * n._23, m._01 * n._20
			+ m._11 * n._21
			+ m._21 * n._22
			+ m._31 * n._23,
			m._02 * n._20
			+ m._12 * n._21
			+ m._22 * n._22
			+ m._32 * n._23, m._03 * n._20
			+ m._13 * n._21
			+ m._23 * n._22
			+ m._33 * n._23,
			m._00 * n._30
			+ m._10 * n._31
			+ m._20 * n._32
			+ m._30 * n._33, m._01 * n._30
			+ m._11 * n._31
			+ m._21 * n._32
			+ m._31 * n._33,
			m._02 * n._30
			+ m._12 * n._31
			+ m._22 * n._32
			+ m._32 * n._33, m._03 * n._30
			+ m._13 * n._31
			+ m._23 * n._32
			+ m._33 * n._33);
	}

	@:op(a * b)
	static inline function postMulVec4(m:Mat4, v:Vec4):Vec4 {
		var m:FastMatrix4 = m;
		return new Vec4(m._00 * v.x
			+ m._10 * v.y
			+ m._20 * v.z
			+ m._30 * v.w, m._01 * v.x
			+ m._11 * v.y
			+ m._21 * v.z
			+ m._31 * v.w,
			m._02 * v.x
			+ m._12 * v.y
			+ m._22 * v.z
			+ m._32 * v.w, m._03 * v.x
			+ m._13 * v.y
			+ m._23 * v.z
			+ m._33 * v.w);
	}

	@:op(a * b)
	static inline function preMulVec4(v:Vec4, m:Mat4):Vec4 {
		return new Vec4(v.dot(m[0]), v.dot(m[1]), v.dot(m[2]), v.dot(m[3]));
	}

	@:op(a * b) @:commutative
	static inline function mulScalar(m:Mat4, f:FastFloat):Mat4 {
		var m:FastMatrix4 = m;
		return new Mat4(m._00 * f, m._01 * f, m._02 * f, m._03 * f, m._10 * f, m._11 * f, m._12 * f, m._13 * f, m._20 * f, m._21 * f, m._22 * f, m._23 * f,
			m._30 * f, m._31 * f, m._32 * f, m._33 * f);
	}

	@:op(a / b)
	static inline function div(m:Mat4, n:Mat4):Mat4
		return m.matrixCompMult(1.0 / n);

	@:op(a / b)
	static inline function divScalar(m:Mat4, f:FastFloat):Mat4 {
		var m:FastMatrix4 = m;
		return new Mat4(m._00 / f, m._01 / f, m._02 / f, m._03 / f, m._10 / f, m._11 / f, m._12 / f, m._13 / f, m._20 / f, m._21 / f, m._22 / f, m._23 / f,
			m._30 / f, m._31 / f, m._32 / f, m._33 / f);
	}

	@:op(a / b)
	static inline function divScalarInv(f:FastFloat, m:Mat4):Mat4 {
		var m:FastMatrix4 = m;
		return new Mat4(f / m._00, f / m._01, f / m._02, f / m._03, f / m._10, f / m._11, f / m._12, f / m._13, f / m._20, f / m._21, f / m._22, f / m._23,
			f / m._30, f / m._31, f / m._32, f / m._33);
	}

	@:op(a == b)
	static inline function equal(m:Mat4, n:Mat4):Bool {
		return m[0] == n[0] && m[1] == n[1] && m[2] == n[2] && m[3] == n[3];
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
